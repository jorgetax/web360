-- Aspirante: GDA00380-OT
-- GitHub: https://github.com/jorgetax/web360.git
-- Licencia: MIT - https://github.com/jorgetax/web360?tab=BSD-2-Clause-1-ov-file
-- Gestor de base de datos: SQL Server 2022 Developer
-- Fecha: 02/12/2024

CREATE DATABASE commerce
    ON
    ( NAME = web360_data,
        FILENAME = '/var/opt/mssql/data/commerce_data.mdf',
        SIZE = 10,
        MAXSIZE = 50,
        FILEGROWTH = 5)
    LOG ON
    ( NAME = web360_log,
        FILENAME = '/var/opt/mssql/data/commerce_log.ldf',
        SIZE = 5 MB,
        MAXSIZE = 25 MB,
        FILEGROWTH = 5 MB );
GO;

USE commerce;
GO;

CREATE SCHEMA sp;
GO;

CREATE SCHEMA vw;
GO;

CREATE SCHEMA system;
GO;

CREATE SCHEMA users;
GO;

CREATE SCHEMA organizations;
GO;

CREATE SCHEMA products;
GO;

CREATE SCHEMA orders;
GO;

-- https://learn.microsoft.com/es-es/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16
-- openjson type: 0 = null, 1 = int, 2 = float, 3 = string, 4 = boolean, 5 = array, 6 = object
CREATE OR ALTER FUNCTION system.validate_json(@data NVARCHAR(MAX))
    RETURNS BIT
AS
BEGIN
    IF ISJSON(@data) = 0 RETURN 0;
    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);
    IF @IS_OBJECT > 1 RETURN 0;
    RETURN 1;
END;
GO;

CREATE TABLE system.states
(
    state_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code       NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label      NVARCHAR(50) NOT NULL CHECK (LEN(label) > 0),
    deleted_at DATETIME,
    created_at DATETIME     NOT NULL        DEFAULT GETDATE(),
    updated_at DATETIME     NOT NULL        DEFAULT GETDATE()
);
GO;

CREATE OR ALTER TRIGGER system.trg_states_updated_at
    ON system.states
    AFTER UPDATE
    AS
BEGIN
    UPDATE system.states
    SET updated_at = GETDATE()
    WHERE state_uuid IN (SELECT state_uuid FROM DELETED);
END;
GO;

CREATE OR ALTER PROC sp.sp_create_state @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(state_uuid UNIQUEIDENTIFIER);

        INSERT INTO system.states (code, label)
        OUTPUT INSERTED.state_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH (code NVARCHAR(50), label NVARCHAR(50));

        COMMIT;

        SELECT * FROM system.states WHERE state_uuid = (SELECT state_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC sp.sp_create_state '{"code": "active", "label": "Activo"}';
EXEC sp.sp_create_state '{"code": "inactive", "label": "Inactivo"}';
EXEC sp.sp_create_state '{"code": "deleted", "label": "Eliminado"}';
EXEC sp.sp_create_state '{"code": "disabled", "label": "Desactivado"}';
EXEC sp.sp_create_state '{"code": "enabled", "label": "Habilitado"}';
GO;

CREATE OR ALTER PROC sp.sp_update_state @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE system.states
        SET label = COALESCE(JSON_VALUE(@data, '$.label'), label)
        WHERE state_uuid = JSON_VALUE(@data, '$.id')
          AND code NOT IN ('deleted', 'inactive');

        COMMIT;

        SELECT * FROM system.states WHERE state_uuid = JSON_VALUE(@data, '$.id');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER VIEW vw.vw_states AS
SELECT *
FROM system.states
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code IN ('deleted', 'inactive'));
GO;

CREATE TABLE system.roles
(
    role_uuid  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code       NVARCHAR(50)     NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label      NVARCHAR(50)     NOT NULL CHECK (LEN(label) > 0),
    state_uuid UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    deleted_at DATETIME,
    created_at DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at DATETIME         NOT NULL    DEFAULT GETDATE()
);
GO;

CREATE OR ALTER TRIGGER system.trg_roles_updated_at
    ON system.roles
    AFTER UPDATE
    AS
BEGIN
    UPDATE system.roles
    SET updated_at = GETDATE()
    WHERE role_uuid IN (SELECT role_uuid FROM DELETED);
END;
GO;

CREATE OR ALTER PROC sp.sp_create_role @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(role_uuid UNIQUEIDENTIFIER);

        INSERT INTO system.roles (code, label, state_uuid)
        OUTPUT INSERTED.role_uuid INTO @InsertedRows
        SELECT r.code, r.label, s.state_uuid
        FROM OPENJSON(@data) WITH (code NVARCHAR(50), label NVARCHAR(50)) AS r,
             system.states s
        WHERE s.code = 'active';

        COMMIT;

        SELECT * FROM system.roles WHERE role_uuid = (SELECT role_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC sp.sp_create_role '{"code": "admin", "label": "Administrador"}';
EXEC sp.sp_create_role '{"code": "customer", "label": "Cliente"}';
EXEC sp.sp_create_role '{"code": "seller", "label": "Vendedor"}';
GO;

CREATE OR ALTER VIEW vw.vw_roles AS
SELECT *
FROM system.roles
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');
GO;

CREATE TABLE users.users
(
    user_uuid  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    first_name NVARCHAR(50)     NOT NULL,
    last_name  NVARCHAR(50)     NOT NULL,
    email      NVARCHAR(100)    NOT NULL UNIQUE CHECK (LEN(email) > 0),
    birth_date DATE,
    state_uuid UNIQUEIDENTIFIER NOT NULL,
    deleted_at DATETIME,
    created_at DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at DATETIME         NOT NULL    DEFAULT GETDATE()
);
GO;

CREATE OR ALTER TRIGGER users.trg_users_updated_at
    ON users.users
    AFTER UPDATE
    AS
BEGIN
    UPDATE users.users
    SET updated_at = GETDATE()
    WHERE user_uuid IN (SELECT user_uuid FROM DELETED);
END;
GO;

CREATE TABLE users.passwords
(
    credential_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid       UNIQUEIDENTIFIER NOT NULL REFERENCES users.users (user_uuid) ON DELETE CASCADE,
    hash            NVARCHAR(100)    NOT NULL,
    salt            NVARCHAR(100)    NOT NULL,
    created_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    CONSTRAINT uc_user_password UNIQUE (user_uuid)
);
GO;

CREATE OR ALTER TRIGGER users.trg_passwords_updated_at
    ON users.passwords
    AFTER UPDATE
    AS
BEGIN
    UPDATE users.passwords
    SET updated_at = GETDATE()
    WHERE credential_uuid IN (SELECT credential_uuid FROM DELETED);
END;
GO;

CREATE TABLE users.users_roles
(
    user_role_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid      UNIQUEIDENTIFIER NOT NULL REFERENCES users.users (user_uuid) ON DELETE NO ACTION,
    role_uuid      UNIQUEIDENTIFIER NOT NULL REFERENCES system.roles (role_uuid) ON DELETE NO ACTION,
    deleted_at     DATETIME,
    created_at     DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at     DATETIME         NOT NULL    DEFAULT GETDATE(),
    CONSTRAINT uc_user_role UNIQUE (user_uuid, role_uuid)
);
GO;

CREATE OR ALTER TRIGGER users.trg_users_roles_updated_at
    ON users.users_roles
    AFTER UPDATE
    AS
BEGIN
    UPDATE users.users_roles
    SET updated_at = GETDATE()
    WHERE user_role_uuid IN (SELECT user_role_uuid FROM DELETED);
END;
GO;

CREATE TABLE organizations.organizations
(
    organization_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name              NVARCHAR(50)     NOT NULL,
    description       NVARCHAR(255)    NOT NULL,
    state_uuid        UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    deleted_at        DATETIME,
    created_at        DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at        DATETIME         NOT NULL    DEFAULT GETDATE()
);
GO;

CREATE OR ALTER TRIGGER organizations.trg_organizations_updated_at
    ON organizations.organizations
    AFTER UPDATE
    AS
BEGIN
    UPDATE organizations.organizations
    SET updated_at = GETDATE()
    WHERE organization_uuid IN (SELECT organization_uuid FROM DELETED);
END;
GO;

CREATE TABLE organizations.organization_users
(
    organization_user_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    organization_uuid       UNIQUEIDENTIFIER NOT NULL REFERENCES organizations.organizations (organization_uuid) ON DELETE CASCADE,
    user_uuid               UNIQUEIDENTIFIER NOT NULL REFERENCES users.users (user_uuid) ON DELETE CASCADE,
    state_uuid              UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    deleted_at              DATETIME,
    created_at              DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at              DATETIME         NOT NULL    DEFAULT GETDATE(),
    CONSTRAINT uc_organization_user UNIQUE (organization_uuid, user_uuid)
);
GO;

CREATE OR ALTER TRIGGER organizations.trg_organization_users_updated_at
    ON organizations.organization_users
    AFTER UPDATE
    AS
BEGIN
    UPDATE organizations.organization_users
    SET updated_at = GETDATE()
    WHERE organization_user_uuid IN (SELECT organization_user_uuid FROM DELETED);
END;
GO;

CREATE OR ALTER PROC sp.sp_create_organization @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(organization_uuid UNIQUEIDENTIFIER);

        INSERT INTO organizations.organizations (name, description, state_uuid)
        OUTPUT INSERTED.organization_uuid INTO @InsertedRows
        SELECT o.name, o.description, s.state_uuid
        FROM OPENJSON(@data) WITH (name NVARCHAR(50), description NVARCHAR(255)) o
                 JOIN system.states s ON s.code = 'active';

        DECLARE @user NVARCHAR(MAX) = JSON_QUERY(@data, '$[0].user');
        DECLARE @InsertedUserRows TABLE(user_uuid UNIQUEIDENTIFIER);

        INSERT INTO users.users (first_name, last_name, email, birth_date, state_uuid)
        OUTPUT INSERTED.user_uuid INTO @InsertedUserRows
        SELECT first_name, last_name, email, birth_date, s.state_uuid
        FROM OPENJSON(@user) WITH (
            first_name NVARCHAR(50),
            last_name NVARCHAR(50),
            email NVARCHAR(100),
            birth_date DATE ,
            state UNIQUEIDENTIFIER), system.states s
        WHERE s.code = 'active';

        DECLARE @password NVARCHAR(MAX) = JSON_QUERY(@data, '$[0].password');

        INSERT INTO users.passwords (user_uuid, hash, salt)
        SELECT user_uuid, hash, salt
        FROM @InsertedUserRows, OPENJSON(@password) WITH (hash NVARCHAR(100), salt NVARCHAR(100));

        INSERT INTO users.users_roles (user_uuid, role_uuid)
        SELECT user_uuid, role_uuid
        FROM @InsertedUserRows, system.roles
        WHERE code = 'admin';

        INSERT INTO organizations.organization_users (organization_uuid, user_uuid, state_uuid)
        SELECT organization_uuid, user_uuid, state_uuid
        FROM @InsertedRows, @InsertedUserRows, system.states
        WHERE code = 'active';

        COMMIT;

        SELECT organization_user_uuid as id
        FROM organizations.organization_users
        WHERE organization_uuid = (SELECT organization_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER PROC sp.sp_sign_in @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    BEGIN TRY
        DECLARE @user_uuid UNIQUEIDENTIFIER = (SELECT user_uuid
                                               FROM users.users
                                               WHERE email = JSON_VALUE(@data, '$.email')
                                                 AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active'));

        IF @user_uuid IS NULL RAISERROR ('User not found', 16, 1);
        SELECT p.user_uuid AS id, p.hash, p.salt FROM users.passwords p WHERE user_uuid = @user_uuid;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER PROC sp.sp_create_user @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE( user_uuid UNIQUEIDENTIFIER);

        INSERT INTO users.users (first_name, last_name, email, birth_date, state_uuid)
        OUTPUT INSERTED.user_uuid INTO @InsertedRows
        SELECT first_name, last_name, email, birth_date, s.state_uuid
        FROM OPENJSON(@data) WITH (
            first_name NVARCHAR(50),
            last_name NVARCHAR(50),
            email NVARCHAR(100),
            birth_date DATE)
                 JOIN system.states s ON s.code = 'active';

        INSERT INTO users.passwords (user_uuid, hash, salt)
        VALUES ((SELECT user_uuid FROM @InsertedRows), JSON_VALUE(@data, '$.password.hash'),
                JSON_VALUE(@data, '$.password.salt'));

        INSERT INTO users.users_roles (user_uuid, role_uuid)
        SELECT user_uuid, role_uuid
        FROM @InsertedRows, system.roles
        WHERE code = JSON_VALUE(@data, '$.role')
          AND JSON_VALUE(@data, '$.role') NOT IN ('admin');

        COMMIT;

        SELECT * FROM users.users WHERE user_uuid = (SELECT user_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER PROC sp.sp_update_user @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.users
        SET first_name = COALESCE(JSON_VALUE(@data, '$.first_name'), first_name),
            last_name  = COALESCE(JSON_VALUE(@data, '$.last_name'), last_name),
            email      = COALESCE(JSON_VALUE(@data, '$.email'), email),
            birth_date = COALESCE(JSON_VALUE(@data, '$.birth_date'), birth_date)
        WHERE user_uuid = JSON_VALUE(@data, '$.id')
          AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;

        SELECT s.user_uuid as id, CONCAT(s.first_name, ' ', s.last_name) as display_name, s.updated_at, s.created_at
        FROM users.users s
        WHERE user_uuid = JSON_VALUE(@data, '$.id');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER PROC sp.sp_delete_user @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.users
        SET state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'deleted')
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid')
          AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;
        SELECT 'deleted' AS status;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END
GO;

CREATE OR ALTER PROCEDURE sp.sp_update_user_state @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.users
        SET state_uuid = JSON_VALUE(@data, '$.state_uuid')
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid')
          AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;
        SELECT 'updated' AS status;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END
GO;

CREATE TABLE products.categories
(
    category_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code          NVARCHAR(50)     NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label         NVARCHAR(50)     NOT NULL CHECK (LEN(label) > 0),
    state_uuid    UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    deleted_at    DATETIME,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE()
);
GO;

CREATE OR ALTER PROC sp.sp_create_category @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(category_uuid UNIQUEIDENTIFIER);
        PRINT @data;
        INSERT INTO products.categories (code, label, state_uuid)
        OUTPUT INSERTED.category_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH (code NVARCHAR(50), label NVARCHAR(50), state UNIQUEIDENTIFIER);

        COMMIT;

        SELECT * FROM products.categories WHERE category_uuid = (SELECT category_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER VIEW vw.vw_categories AS
SELECT *
FROM products.categories
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');
GO;

CREATE OR ALTER PROC sp.sp_update_category @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE products.categories
        SET label      = COALESCE(JSON_VALUE(@data, '$.label'), label),
            state_uuid = COALESCE(JSON_VALUE(@data, '$.state'), state_uuid)
        WHERE category_uuid = JSON_VALUE(@data, '$.id');

        COMMIT;

        SELECT * FROM products.categories WHERE category_uuid = JSON_VALUE(@data, '$.id');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE TABLE products.products
(
    product_uuid  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    category_uuid UNIQUEIDENTIFIER NOT NULL REFERENCES products.categories (category_uuid) ON DELETE NO ACTION,
    title         NVARCHAR(100)    NOT NULL CHECK (LEN(title) > 0),
    description   NVARCHAR(255)    NOT NULL,
    price         DECIMAL(10, 2)   NOT NULL CHECK (price > 0),
    stock         INT              NOT NULL    DEFAULT 0,
    state_uuid    UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    deleted_at    DATETIME,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE()
);
GO;

CREATE OR ALTER PROC sp.sp_create_product @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(product_uuid UNIQUEIDENTIFIER);

        INSERT INTO products.products (category_uuid, title, description, price, state_uuid)
        OUTPUT INSERTED.product_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH (
            category UNIQUEIDENTIFIER,
            title NVARCHAR(100),
            description NVARCHAR(255),
            price DECIMAL(10, 2),
            state UNIQUEIDENTIFIER);

        COMMIT;

        SELECT * FROM products.products WHERE product_uuid = (SELECT product_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER VIEW vw.vw_products AS
SELECT *
FROM products.products
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');
GO;

CREATE OR ALTER PROC sp.sp_update_product @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE products.products
        SET category_uuid = COALESCE(JSON_VALUE(@data, '$.category'), category_uuid),
            title         = COALESCE(JSON_VALUE(@data, '$.title'), title),
            description   = COALESCE(JSON_VALUE(@data, '$.description'), description),
            price         = COALESCE(JSON_VALUE(@data, '$.price'), price),
            stock         = COALESCE(JSON_VALUE(@data, '$.stock'), stock),
            state_uuid    = COALESCE(JSON_VALUE(@data, '$.state'), state_uuid)
        WHERE product_uuid = JSON_VALUE(@data, '$.id');

        COMMIT;

        SELECT * FROM products.products WHERE product_uuid = JSON_VALUE(@data, '$.id');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER PROC sp.sp_delete_product @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE products.products
        SET state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'deleted')
        WHERE product_uuid = JSON_VALUE(@data, '$.id')
          AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;
        SELECT 'deleted' AS status;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE TABLE orders.orders
(
    order_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid  UNIQUEIDENTIFIER NOT NULL REFERENCES users.users (user_uuid) ON DELETE NO ACTION,
    items      INT              NOT NULL    DEFAULT 0,
    amount     DECIMAL(10, 2)   NOT NULL    DEFAULT 0,
    state_uuid UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    deleted_at DATETIME,
    created_at DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at DATETIME         NOT NULL    DEFAULT GETDATE()
);
GO;

CREATE OR ALTER TRIGGER orders.trg_orders_updated_at
    ON orders.orders
    AFTER UPDATE
    AS
BEGIN
    UPDATE orders.orders
    SET updated_at = GETDATE()
    WHERE order_uuid IN (SELECT order_uuid FROM DELETED);
END;
GO;

CREATE TABLE orders.order_items
(
    order_item_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    order_uuid      UNIQUEIDENTIFIER NOT NULL REFERENCES orders.orders (order_uuid) ON DELETE NO ACTION,
    product_uuid    UNIQUEIDENTIFIER NOT NULL REFERENCES products.products (product_uuid) ON DELETE NO ACTION,
    quantity        INT              NOT NULL,
    price           DECIMAL(10, 2)   NOT NULL,
    total           DECIMAL(10, 2)   NOT NULL,
    deleted_at      DATETIME,
    created_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at      DATETIME         NOT NULL    DEFAULT GETDATE()
);
GO;

CREATE OR ALTER TRIGGER orders.trg_order_items_updated_at
    ON orders.order_items
    AFTER UPDATE
    AS
BEGIN
    UPDATE orders.order_items
    SET updated_at = GETDATE()
    WHERE order_item_uuid IN (SELECT order_item_uuid FROM DELETED);
END;
GO;

CREATE OR ALTER PROC sp.sp_create_order @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(order_uuid UNIQUEIDENTIFIER);

        INSERT INTO orders.orders (user_uuid, state_uuid)
        OUTPUT INSERTED.order_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH ( [user] UNIQUEIDENTIFIER, state UNIQUEIDENTIFIER);

        DECLARE @order_uuid UNIQUEIDENTIFIER = (SELECT order_uuid FROM @InsertedRows);
        DECLARE @items NVARCHAR(MAX) = JSON_QUERY(@data, '$.items');

        INSERT INTO orders.order_items (order_uuid, product_uuid, quantity, price, total)
        SELECT @order_uuid, p.product_uuid, i.quantity, p.price, i.quantity * p.price
        FROM OPENJSON(@items) WITH (id UNIQUEIDENTIFIER, quantity INT) i
                 JOIN products.products p ON i.id = p.product_uuid;

        UPDATE orders.orders
        SET items  = (SELECT COUNT(*) FROM OPENJSON(@items)),
            amount = (SELECT SUM(total) FROM orders.order_items WHERE order_uuid = @order_uuid)
        WHERE order_uuid = @order_uuid;

        COMMIT;

        SELECT s.order_uuid as id, s.user_uuid as [user], s.items, s.amount, s.created_at
        FROM orders.orders s
        WHERE order_uuid = (SELECT order_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

CREATE OR ALTER VIEW vw.vw_orders AS
SELECT *
FROM orders.orders
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');
GO;

CREATE OR ALTER PROC sp.sp_update_order @data NVARCHAR(MAX)
AS BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @order_uuid UNIQUEIDENTIFIER = JSON_VALUE(@data, '$.id');
        DECLARE @items NVARCHAR(MAX) = JSON_QUERY(@data, '$.items');

        UPDATE orders.orders
        SET state_uuid = COALESCE(JSON_VALUE(@data, '$.state'), state_uuid)
        WHERE order_uuid = @order_uuid;

        UPDATE orders.order_items SET deleted_at = GETDATE() WHERE order_uuid = @order_uuid;

        INSERT INTO orders.order_items (order_uuid, product_uuid, quantity, price, total)
        SELECT @order_uuid, p.product_uuid, i.quantity, p.price, i.quantity * p.price
        FROM OPENJSON(@items) WITH (id UNIQUEIDENTIFIER, quantity INT) i
                 JOIN products.products p ON i.id = p.product_uuid;

        UPDATE orders.orders
        SET items  = (SELECT COUNT(*) FROM OPENJSON(@items)),
            amount = (SELECT SUM(total) FROM orders.order_items WHERE order_uuid = @order_uuid AND deleted_at IS NULL)
        WHERE order_uuid = @order_uuid;

        COMMIT;

        SELECT s.order_uuid as id, s.user_uuid as [user], s.items, s.amount, s.created_at
        FROM orders.orders s
        WHERE order_uuid = @order_uuid;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;