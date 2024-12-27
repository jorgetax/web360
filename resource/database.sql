-- Aspirante: GDA00380-OT
-- GitHub: https://github.com/jorgetax/web360.git
-- Licencia: MIT - https://github.com/jorgetax/web360?tab=BSD-2-Clause-1-ov-file
-- Gestor de base de datos: SQL Server 2022 Developer
-- Fecha: 02/12/2024

--
-- drop database

USE master;
DROP DATABASE web360;

--
-- database

CREATE DATABASE web360
    ON
    ( NAME = web360_data,
        FILENAME = '/var/opt/mssql/data/web360_data.mdf',
        SIZE = 10,
        MAXSIZE = 50,
        FILEGROWTH = 5)
    LOG ON
    ( NAME = web360_log,
        FILENAME = '/var/opt/mssql/data/web360_log.ldf',
        SIZE = 5 MB,
        MAXSIZE = 25 MB,
        FILEGROWTH = 5 MB );

USE web360;

--
-- system

CREATE SCHEMA sp; -- stored-procedures
CREATE SCHEMA vw; -- views
CREATE SCHEMA system;

-- system tables

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

--
-- states

CREATE TABLE system.states
(
    state_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code       NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label      NVARCHAR(50) NOT NULL CHECK (LEN(label) > 0),
    deleted_at DATETIME,
    created_at DATETIME     NOT NULL        DEFAULT GETDATE(),
    updated_at DATETIME     NOT NULL        DEFAULT GETDATE()
);

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

-- stored-procedures: https://learn.microsoft.com/es-es/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-ver16
-- json: https://learn.microsoft.com/en-us/sql/relational-databases/json/validate-query-and-change-json-data-with-built-in-functions-sql-server?view=sql-server-ver16
-- https://learn.microsoft.com/es-es/sql/t-sql/language-elements/declare-cursor-transact-sql?view=sql-server-ver16

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

-- EXEC sp.sp_update_state '{"state_uuid": "6E0FE96E-39EE-4E1E-B8FA-4CADC44E2A50", "label": "Desactivado"}';

CREATE OR ALTER VIEW vw.vw_states AS
SELECT *
FROM system.states
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code IN ('deleted', 'inactive'));

-- SELECT *
-- FROM vw.vw_states;

--
-- roles

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
        SELECT *
        FROM OPENJSON(@data) WITH (code NVARCHAR(50), label NVARCHAR(50), state_uuid UNIQUEIDENTIFIER);

        COMMIT;

        SELECT * FROM system.roles WHERE role_uuid = (SELECT role_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

-- EXEC sp.sp_create_role '{"code": "user", "label": "Usuario", "state_uuid": "E7633767-F1E3-4021-8487-CF9CD9AC2468"}';
-- EXEC sp.sp_create_role'{"code": "admin", "label": "Administrador", "state_uuid": "E7633767-F1E3-4021-8487-CF9CD9AC2468"}';

-- SELECT *
-- FROM system.roles

CREATE OR ALTER VIEW vw.vw_roles AS
SELECT *
FROM system.roles
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');

-- SELECT *
-- FROM vw.vw_roles;

--
-- users

CREATE SCHEMA users;

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

CREATE TABLE users.customers
(
    customer_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid     UNIQUEIDENTIFIER NOT NULL UNIQUE REFERENCES users.users (user_uuid) ON DELETE NO ACTION,
    customer_id   NVARCHAR(50)     NOT NULL UNIQUE CHECK (LEN(customer_id) > 0),
    state_uuid    UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    deleted_at    DATETIME,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
);

CREATE OR ALTER TRIGGER users.trg_customers_updated_at
    ON users.customers
    AFTER UPDATE
    AS
BEGIN
    UPDATE users.customers
    SET updated_at = GETDATE()
    WHERE customer_uuid IN (SELECT customer_uuid FROM DELETED);
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

-- EXEC sp.sp_sign_in '{"email": "hello@local.com"}';

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
        SELECT *
        FROM OPENJSON(@data) WITH (
            first_name NVARCHAR(50),
            last_name NVARCHAR(50),
            email NVARCHAR(100),
            birth_date DATE ,
            state UNIQUEIDENTIFIER);

        INSERT INTO users.passwords (user_uuid, hash, salt)
        VALUES ((SELECT user_uuid FROM @InsertedRows), JSON_VALUE(@data, '$.password.hash'),
                JSON_VALUE(@data, '$.password.salt'));

        INSERT INTO users.users_roles (user_uuid, role_uuid)
        VALUES ((SELECT user_uuid FROM @InsertedRows), (SELECT role_uuid FROM system.roles WHERE code = 'user'));

        COMMIT;

        SELECT * FROM users.users WHERE user_uuid = (SELECT user_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

-- EXEC sp.sp_create_user'{"first_name": "Hello", "last_name": "World", "email": "info@localhost.com", "birth_date": "2024-02-12", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9", "password": {"hash": "123456", "salt": "123456"}}';

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

-- EXEC sp.sp_update_user '{"id": "361CBC2D-A187-480E-9B2A-87B832368B94", "first_name": "Hello", "last_name": "World", "email": "local@local.com", "birth_date": "2024-02-12"}';

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

-- EXEC sp.sp_delete_user '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94"}';

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

-- EXEC sp.sp_update_user_state'{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

CREATE OR ALTER PROCEDURE sp.sp_create_customer @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(  customer_uuid UNIQUEIDENTIFIER );

        INSERT INTO users.customers (user_uuid, customer_id, state_uuid)
        OUTPUT INSERTED.customer_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH (user_uuid UNIQUEIDENTIFIER, customer_id NVARCHAR(50), state_uuid UNIQUEIDENTIFIER);

        COMMIT;

        SELECT * FROM users.customers WHERE customer_uuid = (SELECT customer_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

-- EXEC sp.sp_create_customer'{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "customer_id": "123456", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

CREATE OR ALTER PROCEDURE sp.sp_update_customer @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.customers
        SET customer_id = COALESCE(JSON_VALUE(@data, '$.customer_id'), customer_id),
            state_uuid  = COALESCE(JSON_VALUE(@data, '$.state_uuid'), state_uuid)
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid');

        COMMIT;

        SELECT c.customer_uuid, c.user_uuid, c.customer_id, s.label AS state, c.created_at, c.updated_at
        FROM users.customers c
                 INNER JOIN system.states s ON c.state_uuid = s.state_uuid
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

-- EXEC sp.sp_update_customer'{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "customer_id": "654321", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

CREATE OR ALTER PROCEDURE sp.sp_delete_customer @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF system.validate_json(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);
    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.customers
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
END;
GO;

-- EXEC sp.sp_delete_customer '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94"}';

--
-- products

CREATE SCHEMA products;

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

-- EXEC sp.sp_create_category '{"code": "rice", "label": "Arroz", "state": "E7633767-F1E3-4021-8487-CF9CD9AC2468"}';
-- EXEC sp.sp_create_category '{"code": "salt", "label": "Sal", "state": "E7633767-F1E3-4021-8487-CF9CD9AC2468"}';

CREATE OR ALTER VIEW vw.vw_categories AS
SELECT *
FROM products.categories
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');

-- SELECT *
-- FROM vw.vw_categories;

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

-- EXEC sp.sp_update_category'{"id": "EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD", "label": "Arroz", "state": "B9436A39-18F5-4C00-B0C2-562F10BB21F9"}';

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

-- EXEC sp.sp_create_product'{"category": "EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD", "title": "Arroz", "description": "Arroz 1kg", "price": 10.50, "state": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

CREATE OR ALTER VIEW vw.vw_products AS
SELECT *
FROM products.products
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');

-- SELECT *
-- FROM vw.vw_products;

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

-- EXEC sp.sp_update_product'{"id": "05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB", "category": "9FC6FD5B-BD84-4F52-BF73-A66755B0CD0E", "title": "Sal", "description": "Sal 1kg", "price": 5.50, "sate": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

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

-- EXEC sp.sp_delete_product '{"product_uuid": "05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB"}';

--
-- orders

CREATE SCHEMA orders;

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

-- EXEC sp.sp_create_order  '{"user": "361CBC2D-A187-480E-9B2A-87B832368B94", "items": [{"id": "05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB", "quantity": 2}]}';

CREATE OR ALTER VIEW vw.vw_orders AS
SELECT *
FROM orders.orders
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code = 'deleted');

-- SELECT *
-- FROM vw.vw_orders;

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

-- EXEC sp.sp_update_order'{"id": "D1D3D3A4-3D3D-4D3D-8D3D-3D3D3D3D3D3D", "state": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9", "items": [{"id": "05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB", "quantity": 2}]}';
