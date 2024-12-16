-- Aspirante: GDA00380-OT
-- GitHub: https://github.com/jorgetax/web360.git
-- Licencia: MIT - https://github.com/jorgetax/web360?tab=BSD-2-Clause-1-ov-file
-- Gestor de base de datos: SQL Server 2022 Developer
-- Fecha: 02/12/2024

-----------------------------------------------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------------------------------------------
--
-- system

CREATE SCHEMA sp;
CREATE SCHEMA vw;
CREATE SCHEMA system;

CREATE TABLE system.states
(
    state_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code       NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label      NVARCHAR(50) NOT NULL CHECK (LEN(label) > 0),
    created_at DATETIME     NOT NULL        DEFAULT GETDATE(),
    updated_at DATETIME     NOT NULL        DEFAULT GETDATE()
);

-- states
INSERT INTO system.states (code, label)
VALUES ('active', 'Activo'),
       ('disabled', 'Deshabilitado'),
       ('inactive', 'Inactivo'),
       ('deleted', 'Eliminado');

SELECT *
FROM system.states;

CREATE OR ALTER VIEW sp.vw_states AS
SELECT *
FROM system.states
WHERE state_uuid NOT IN (SELECT state_uuid FROM system.states WHERE code IN ('deleted', 'inactive'));

SELECT *
FROM system.vw_states;

-- +------------------------------------+--------+-------------+-----------------------+-----------------------+
-- |state_uuid                          |code    |label        |created_at             |updated_at             |
-- +------------------------------------+--------+-------------+-----------------------+-----------------------+
-- |B9436A39-18F5-4C00-B0C2-562F10BB21F9|disabled|Deshabilitado|2024-12-11 00:02:06.137|2024-12-11 00:02:06.137|
-- |51ADB114-CC6C-4A72-AD42-F8B53E2D62A9|active  |Activo       |2024-12-11 00:02:06.137|2024-12-11 00:02:06.137|
-- +------------------------------------+--------+-------------+-----------------------+-----------------------+

CREATE TABLE system.roles
(
    role_uuid  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code       NVARCHAR(50)     NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label      NVARCHAR(50)     NOT NULL CHECK (LEN(label) > 0),
    state_uuid UNIQUEIDENTIFIER NOT NULL,
    created_at DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at DATETIME         NOT NULL    DEFAULT GETDATE()
);

-- stored-procedures: https://learn.microsoft.com/es-es/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-ver16
-- json: https://learn.microsoft.com/en-us/sql/relational-databases/json/validate-query-and-change-json-data-with-built-in-functions-sql-server?view=sql-server-ver16

CREATE OR ALTER PROC sp.sp_create_role @role NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@role) = 0 RAISERROR ('Invalid JSON', 16, 1);

    -- https://learn.microsoft.com/es-es/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16
    -- openjson type: 0 = null, 1 = int, 2 = float, 3 = string, 4 = boolean, 5 = array, 6 = object
    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@role) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(role_uuid UNIQUEIDENTIFIER);

        INSERT INTO system.roles (code, label, state_uuid)
        OUTPUT INSERTED.role_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@role) WITH (code NVARCHAR(50), label NVARCHAR(50), state_uuid UNIQUEIDENTIFIER);

        COMMIT;

        SELECT * FROM system.roles WHERE role_uuid = (SELECT role_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC sp_create_role '{"code": "user", "label": "Usuario", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';
EXEC sp_create_role'{"code": "admin", "label": "Administrador", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

SELECT *
FROM system.roles

CREATE OR ALTER VIEW system.vw_roles AS
SELECT r.role_uuid,
       r.code,
       r.label,
       s.label AS state
FROM system.roles r
         INNER JOIN system.states s ON r.state_uuid = s.state_uuid;

SELECT *
FROM system.vw_roles;

-- +------------------------------------+-----+-------------+------+
-- |role_uuid                           |code |label        |state |
-- +------------------------------------+-----+-------------+------+
-- |B6697638-E93D-4977-B5B5-1F09788E46BE|admin|Administrador|Activo|
-- |817B6830-6561-4C7E-9051-A0CF7E27BAAE|user |Usuario      |Activo|
-- +------------------------------------+-----+-------------+------+

-----------------------------------------------------------------------------------------------------------------------
--
-- users

CREATE SCHEMA users;

CREATE TABLE users.users
(
    user_uuid   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    first_name  NVARCHAR(50)  NOT NULL,
    last_name   NVARCHAR(50)  NOT NULL,
    email       NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(email) > 0),
    birth_date  DATE,
    state_uuid  UNIQUEIDENTIFIER NOT NULL,
    created_at  DATETIME      NOT NULL       DEFAULT GETDATE(),
    updated_at  DATETIME      NOT NULL       DEFAULT GETDATE()
);

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

CREATE TABLE users.users_roles
(
    user_role_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid      UNIQUEIDENTIFIER NOT NULL REFERENCES users.users (user_uuid) ON DELETE NO ACTION,
    role_uuid      UNIQUEIDENTIFIER NOT NULL REFERENCES system.roles (role_uuid) ON DELETE NO ACTION,
    created_at     DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at     DATETIME         NOT NULL    DEFAULT GETDATE(),
    CONSTRAINT uc_user_role UNIQUE (user_uuid, role_uuid)
);

CREATE TABLE users.customers
(
    customer_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid     UNIQUEIDENTIFIER NOT NULL UNIQUE REFERENCES users.users (user_uuid) ON DELETE NO ACTION,
    customer_id   NVARCHAR(50)     NOT NULL UNIQUE CHECK (LEN(customer_id) > 0),
    state_uuid    UNIQUEIDENTIFIER NOT NULL,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
);

CREATE OR ALTER PROC users.sp_create_user @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE( user_uuid UNIQUEIDENTIFIER);

        INSERT INTO users.users (first_name, last_name, email, birth_date, state_uuid)
        OUTPUT INSERTED.user_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data)
                      WITH ( first_name NVARCHAR(50), last_name NVARCHAR(50), email NVARCHAR(100), birth_date DATE , state_uuid UNIQUEIDENTIFIER);

        INSERT INTO users.passwords (user_uuid, hash, salt)
        VALUES ((SELECT user_uuid FROM @InsertedRows), JSON_VALUE(@data, '$.password.hash'), JSON_VALUE(@data, '$.password.salt'));

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

EXEC users.sp_create_user '{"first_name": "Hello", "last_name": "World", "email": "info@localhost.com", "birth_date": "2024-02-12", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9", "password": {"hash": "123456", "salt": "123456"}}';

-- +------------------------------------+----------+---------+------------------+----------+------------------------------------+-----------------------+-----------------------+
-- |user_uuid                           |first_name|last_name|email             |birth_date|state_uuid                          |created_at             |updated_at             |
-- +------------------------------------+----------+---------+------------------+----------+------------------------------------+-----------------------+-----------------------+
-- |361CBC2D-A187-480E-9B2A-87B832368B94|Hello     |World    |info@localhost.com|2024-02-12|51ADB114-CC6C-4A72-AD42-F8B53E2D62A9|2024-12-12 22:43:17.907|2024-12-12 22:43:17.907|
-- +------------------------------------+----------+---------+------------------+----------+------------------------------------+-----------------------+-----------------------+

CREATE OR ALTER PROC users.sp_update_user @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.users
        SET first_name = COALESCE(JSON_VALUE(@data, '$.first_name'), first_name),
            last_name  = COALESCE(JSON_VALUE(@data, '$.last_name'), last_name),
            email      = COALESCE(JSON_VALUE(@data, '$.email'), email),
            birth_date = COALESCE(JSON_VALUE(@data, '$.birth_date'), birth_date)
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid');

        COMMIT;

        SELECT * FROM users.users WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC users.sp_update_user '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "first_name": "Hello", "last_name": "World", "email": "local@local.com", "birth_date": "2024-02-12"}';

-- +------------------------------------+----------+---------+---------------+----------+------------------------------------+-----------------------+-----------------------+
-- |user_uuid                           |first_name|last_name|email          |birth_date|state_uuid                          |created_at             |updated_at             |
-- +------------------------------------+----------+---------+---------------+----------+------------------------------------+-----------------------+-----------------------+
-- |361CBC2D-A187-480E-9B2A-87B832368B94|Hello     |World    |local@local.com|2024-02-12|51ADB114-CC6C-4A72-AD42-F8B53E2D62A9|2024-12-12 22:43:17.907|2024-12-12 22:43:17.907|
-- +------------------------------------+----------+---------+---------------+----------+------------------------------------+-----------------------+-----------------------+

CREATE OR ALTER PROC users.sp_delete_user @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.users
        SET state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'deleted')
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid') AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;
        SELECT 'deleted' AS status;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END
GO;

SELECT *
FROM users.users;

EXEC users.sp_delete_user '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94"}';

-- +-------+
-- |status |
-- +-------+
-- |deleted|
-- +-------+

CREATE OR ALTER PROCEDURE users.sp_update_user_state @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.users
        SET state_uuid = JSON_VALUE(@data, '$.state_uuid')
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid') AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;
        SELECT 'updated' AS status;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END
GO;

EXEC users.sp_update_user_state '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

-- +-------+
-- |status |
-- +-------+
-- |updated|
-- +-------+

CREATE OR ALTER PROCEDURE users.sp_create_customer @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(customer_uuid UNIQUEIDENTIFIER);

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

EXEC users.sp_create_customer '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "customer_id": "123456", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

-- +------------------------------------+------------------------------------+-----------+------------------------------------+-----------------------+-----------------------+
-- |customer_uuid                       |user_uuid                           |customer_id|state_uuid                          |created_at             |updated_at             |
-- +------------------------------------+------------------------------------+-----------+------------------------------------+-----------------------+-----------------------+
-- |EEC3AB66-9870-4BFA-B824-5C7DCB251879|361CBC2D-A187-480E-9B2A-87B832368B94|123456     |51ADB114-CC6C-4A72-AD42-F8B53E2D62A9|2024-12-12 23:04:12.257|2024-12-12 23:04:12.257|
-- +------------------------------------+------------------------------------+-----------+------------------------------------+-----------------------+-----------------------+

CREATE OR ALTER PROCEDURE users.sp_update_customer @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

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

EXEC users.sp_update_customer '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "customer_id": "654321", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

-- +------------------------------------+------------------------------------+-----------+------+-----------------------+-----------------------+
-- |customer_uuid                       |user_uuid                           |customer_id|state |created_at             |updated_at             |
-- +------------------------------------+------------------------------------+-----------+------+-----------------------+-----------------------+
-- |EEC3AB66-9870-4BFA-B824-5C7DCB251879|361CBC2D-A187-480E-9B2A-87B832368B94|654321     |Activo|2024-12-12 23:04:12.257|2024-12-12 23:04:12.257|
-- +------------------------------------+------------------------------------+-----------+------+-----------------------+-----------------------+

CREATE OR ALTER PROCEDURE users.sp_delete_customer @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE users.customers
        SET state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'deleted')
        WHERE user_uuid = JSON_VALUE(@data, '$.user_uuid') AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;
        SELECT 'deleted' AS status;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

SELECT c.customer_id, c.user_uuid, s.label AS state
FROM users.customers c
         INNER JOIN system.states s ON c.state_uuid = s.state_uuid;

-- +-----------+------------------------------------+---------+
-- |customer_id|user_uuid                           |state    |
-- +-----------+------------------------------------+---------+
-- |654321     |361CBC2D-A187-480E-9B2A-87B832368B94|Eliminado|
-- +-----------+------------------------------------+---------+

EXEC users.sp_delete_customer '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94"}';

-- +-------+
-- |status |
-- +-------+
-- |deleted|
-- +-------+

-----------------------------------------------------------------------------------------------------------------------

--
-- products

CREATE SCHEMA products;

CREATE TABLE products.categories
(
    category_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code          NVARCHAR(50)     NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label         NVARCHAR(50)     NOT NULL,
    state_uuid    UNIQUEIDENTIFIER NOT NULL REFERENCES system.states (state_uuid) ON DELETE NO ACTION,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE()
);

CREATE OR ALTER PROC products.sp_create_category @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(category_uuid UNIQUEIDENTIFIER);

        INSERT INTO products.categories (code, label, state_uuid)
        OUTPUT INSERTED.category_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH (code NVARCHAR(50), label NVARCHAR(50), state_uuid UNIQUEIDENTIFIER);

        COMMIT;

        SELECT * FROM products.categories WHERE category_uuid = (SELECT category_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC products.sp_create_category '{"code": "rice", "label": "Arroz", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';
EXEC products.sp_create_category '{"code": "salt", "label": "Sal", "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

SELECT c.category_uuid AS category_uuid,
       c.code AS code,
       c.label AS label,
       s.code AS state,
       c.created_at AS created_at,
       c.updated_at AS updated_at
FROM products.categories c INNER JOIN system.states s ON c.state_uuid = s.state_uuid;

CREATE OR ALTER VIEW products.vw_categories AS
SELECT c.category_uuid,
       c.code,
       c.label,
       s.code AS state,
       c.created_at,
       c.updated_at
FROM products.categories c
         INNER JOIN system.states s ON c.state_uuid = s.state_uuid
WHERE s.code = 'active';

SELECT *
FROM products.vw_categories;

-- +------------------------------------+-----+------+------+-----------------------+-----------------------+
-- |category_uuid                       |code |label |state |created_at             |updated_at             |
-- +------------------------------------+-----+------+------+-----------------------+-----------------------+
-- |EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD|rice |Arroz |active|2024-12-13 11:09:57.650|2024-12-13 11:09:57.650|
-- |9FC6FD5B-BD84-4F52-BF73-A66755B0CD0E|salt |Sal   |active|2024-12-13 11:09:57.650|2024-12-13 11:09:57.650|
-- |C1FC3DE4-73E5-4C5B-AF30-B957F204B412|sugar|Azúcar|active|2024-12-13 11:09:57.650|2024-12-13 11:09:57.650|
-- +------------------------------------+-----+------+------+-----------------------+-----------------------+

CREATE OR ALTER PROC products.sp_update_category @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE products.categories
        SET label      = COALESCE(JSON_VALUE(@data, '$.label'), label),
            state_uuid = COALESCE(JSON_VALUE(@data, '$.state_uuid'), state_uuid)
        WHERE category_uuid = JSON_VALUE(@data, '$.category_uuid');

        COMMIT;

        SELECT c.category_uuid AS category_uuid,
               c.code AS code,
               c.label AS label,
               s.code AS state,
               c.created_at AS created_at,
               c.updated_at AS updated_at
        FROM products.categories c INNER JOIN system.states s ON c.state_uuid = s.state_uuid
        WHERE category_uuid = JSON_VALUE(@data, '$.category_uuid');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC products.sp_update_category '{"category_uuid": "EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD", "label": "Arroz", "state_uuid": "B9436A39-18F5-4C00-B0C2-562F10BB21F9"}';

-- +------------------------------------+----+-----+--------+-----------------------+-----------------------+
-- |category_uuid                       |code|label|state   |created_at             |updated_at             |
-- +------------------------------------+----+-----+--------+-----------------------+-----------------------+
-- |EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD|rice|Arroz|disabled|2024-12-13 11:09:57.650|2024-12-13 11:09:57.650|
-- +------------------------------------+----+-----+--------+-----------------------+-----------------------+

CREATE TABLE products.products
(
    product_uuid  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    category_uuid UNIQUEIDENTIFIER NOT NULL,
    title         NVARCHAR(100)    NOT NULL,
    description   NVARCHAR(255)    NOT NULL,
    price         DECIMAL(10, 2)   NOT NULL,
    stock         INT              NOT NULL    DEFAULT 0,
    state_uuid    UNIQUEIDENTIFIER NOT NULL,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    FOREIGN KEY (category_uuid) REFERENCES products.categories (category_uuid) ON DELETE CASCADE
);

CREATE OR ALTER PROC products.sp_create_product @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE(product_uuid UNIQUEIDENTIFIER);

        INSERT INTO products.products (category_uuid, title, description, price, state_uuid)
        OUTPUT INSERTED.product_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH (category_uuid UNIQUEIDENTIFIER, title NVARCHAR(100), description NVARCHAR(255), price DECIMAL(10, 2), state_uuid UNIQUEIDENTIFIER);

        COMMIT;

        SELECT p.product_uuid, p.category_uuid, c.label AS category, p.title, p.description, p.price, p.stock, s.label AS state, p.created_at, p.updated_at
        FROM products.products p
                 INNER JOIN products.categories c ON p.category_uuid = c.category_uuid
                 INNER JOIN system.states s ON p.state_uuid = s.state_uuid
        WHERE product_uuid = (SELECT product_uuid FROM @InsertedRows);
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC products.sp_create_product '{"category_uuid": "EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD", "title": "Arroz", "description": "Arroz 1kg", "price": 10.50, "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+
-- |product_uuid                        |category_uuid                       |category|title|description|price|stock|state |created_at             |updated_at             |
-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+
-- |05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB|EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD|Arroz   |Arroz|Arroz 1kg  |10.50|0    |Activo|2024-12-13 11:19:37.907|2024-12-13 11:19:37.907|
-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+

CREATE OR ALTER VIEW products.vw_products AS
SELECT p.product_uuid,
       p.category_uuid,
       c.label AS category,
       p.title,
       p.description,
       p.price,
       p.stock,
       s.label AS state,
       p.created_at,
       p.updated_at
FROM products.products p
         INNER JOIN products.categories c ON p.category_uuid = c.category_uuid
         INNER JOIN system.states s ON p.state_uuid = s.state_uuid
WHERE s.code = 'active';

SELECT *
FROM products.vw_products;

-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+
-- |product_uuid                        |category_uuid                       |category|title|description|price|stock|state |created_at             |updated_at             |
-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+
-- |05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB|EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD|Arroz   |Arroz|Arroz 1kg  |10.50|0    |Activo|2024-12-13 11:19:37.907|2024-12-13 11:19:37.907|
-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+

CREATE OR ALTER PROC products.sp_update_product @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE products.products
        SET category_uuid = COALESCE(JSON_VALUE(@data, '$.category_uuid'), category_uuid),
            title         = COALESCE(JSON_VALUE(@data, '$.title'), title),
            description   = COALESCE(JSON_VALUE(@data, '$.description'), description),
            price         = COALESCE(JSON_VALUE(@data, '$.price'), price),
            state_uuid    = COALESCE(JSON_VALUE(@data, '$.state_uuid'), state_uuid)
        WHERE product_uuid = JSON_VALUE(@data, '$.product_uuid');

        COMMIT;

        SELECT p.product_uuid,
               p.category_uuid,
               c.label AS category,
               p.title,
               p.description,
               p.price,
               p.stock,
               s.label AS state,
               p.created_at,
               p.updated_at
        FROM products.products p
                 INNER JOIN products.categories c ON p.category_uuid = c.category_uuid
                 INNER JOIN system.states s ON p.state_uuid = s.state_uuid
        WHERE product_uuid = JSON_VALUE(@data, '$.product_uuid');
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC products.sp_update_product  '{"product_uuid": "05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB", "category_uuid": "9FC6FD5B-BD84-4F52-BF73-A66755B0CD0E", "title": "Sal", "description": "Sal 1kg", "price": 5.50, "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+
-- |product_uuid                        |category_uuid                       |category|title|description|price|stock|state |created_at             |updated_at             |
-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+
-- |05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB|9FC6FD5B-BD84-4F52-BF73-A66755B0CD0E|Sal     |Sal  |Sal 1kg    |5.50 |0    |Activo|2024-12-13 11:19:37.907|2024-12-13 11:19:37.907|
-- +------------------------------------+------------------------------------+--------+-----+-----------+-----+-----+------+-----------------------+-----------------------+

CREATE OR ALTER PROC products.sp_delete_product @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE products.products
        SET state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'deleted')
        WHERE product_uuid = JSON_VALUE(@data, '$.product_uuid') AND state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

        COMMIT;
        SELECT 'deleted' AS status;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO;

EXEC products.sp_delete_product '{"product_uuid": "05CF9CF8-A548-4FE3-9F9C-0FB73E7929BB"}';

-- +-------+
-- |status |
-- +-------+
-- |deleted|
-- +-------+

-----------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA orders;

CREATE TABLE orders.orders
(
    order_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid  UNIQUEIDENTIFIER NOT NULL REFERENCES users.users (user_uuid) ON DELETE NO ACTION,
    items      INT              NOT NULL    DEFAULT 0,
    amount     DECIMAL(10, 2)   NOT NULL    DEFAULT 0,
    state_uuid UNIQUEIDENTIFIER NOT NULL,
    created_at DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at DATETIME         NOT NULL    DEFAULT GETDATE()
);

CREATE TABLE orders.order_items
(
    order_item_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    order_uuid      UNIQUEIDENTIFIER NOT NULL REFERENCES orders.orders (order_uuid) ON DELETE NO ACTION,
    product_uuid    UNIQUEIDENTIFIER NOT NULL REFERENCES products.products (product_uuid) ON DELETE NO ACTION,
    quantity        INT              NOT NULL,
    price           DECIMAL(10, 2)   NOT NULL,
    total           DECIMAL(10, 2)   NOT NULL,
    created_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at      DATETIME         NOT NULL    DEFAULT GETDATE()
);


CREATE OR ALTER PROC orders.sp_create_order @data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISJSON(@data) = 0 RAISERROR ('Invalid JSON', 16, 1);

    DECLARE @IS_OBJECT INT = (SELECT COUNT(*) FROM OPENJSON(@data) WHERE [type] = 5);

    IF @IS_OBJECT > 1 RAISERROR ('Only one object is allowed', 16, 1);

    BEGIN TRANSACTION;

    BEGIN TRY
        -- https://learn.microsoft.com/es-es/sql/t-sql/language-elements/declare-cursor-transact-sql?view=sql-server-ver16
        DECLARE @InsertedRows TABLE(order_uuid UNIQUEIDENTIFIER);

        INSERT INTO orders.orders (user_uuid, state_uuid)
        OUTPUT INSERTED.order_uuid INTO @InsertedRows
        SELECT *
        FROM OPENJSON(@data) WITH (user_uuid UNIQUEIDENTIFIER, state_uuid UNIQUEIDENTIFIER);

        DECLARE @order_uuid UNIQUEIDENTIFIER = (SELECT order_uuid FROM @InsertedRows);
        DECLARE @Items TABLE(product_uuid UNIQUEIDENTIFIER,quantity INT)
        INSERT INTO @Items (product_uuid, quantity)
        SELECT *
        FROM OPENJSON(@data, '$.items') WITH (product_uuid UNIQUEIDENTIFIER, quantity INT);

        DECLARE @product_uuid UNIQUEIDENTIFIER;
        DECLARE @quantity INT;
        DECLARE @price DECIMAL(10, 2);

        DECLARE items_cursor CURSOR FOR
        SELECT JSON_VALUE(value, '$.product_uuid'), JSON_VALUE(value, '$.quantity')
        FROM OPENJSON(@Items);

        OPEN items_cursor;
        FETCH NEXT FROM items_cursor INTO @product_uuid, @quantity;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @price = (SELECT price FROM products.products WHERE product_uuid = @product_uuid);

                INSERT INTO orders.order_items (order_uuid, product_uuid, quantity, price, total)
                SELECT @order_uuid,
                       @product_uuid,
                       @quantity,
                       @price,
                       @price * @quantity;

                FETCH NEXT FROM items_cursor INTO @product_uuid, @quantity;
            END;

        CLOSE items_cursor;
        DEALLOCATE items_cursor;

        COMMIT;

        SELECT * FROM orders.orders WHERE order_uuid = @order_uuid;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        IF CURSOR_STATUS('global', 'items_cursor') >= 0
            BEGIN
                CLOSE items_cursor;
                DEALLOCATE items_cursor;
            END;
        THROW;
    END CATCH;
END;
GO;

EXEC orders.sp_create_order '{"user_uuid": "361CBC2D-A187-480E-9B2A-87B832368B94", "items": [{ "product_uuid": "EB49A8AE-AFC2-4ACF-8E57-04CBEC0315DD", "quantity": 5 }, { "product_uuid": "9FC6FD5B-BD84-4F52-BF73-A66755B0CD0E", "quantity": 5 }], "state_uuid": "51ADB114-CC6C-4A72-AD42-F8B53E2D62A9"}';

--
-- Update order

CREATE OR ALTER PROC orders.sp_update_order @order_uuid UNIQUEIDENTIFIER,
                                            @product_uuid UNIQUEIDENTIFIER,
                                            @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT order_uuid FROM orders.orders WHERE order_uuid = @order_uuid)
            BEGIN
                RAISERROR ('Order not found', 16, 1);
            END;

        IF NOT EXISTS (SELECT product_uuid FROM products.products WHERE product_uuid = @product_uuid)
            BEGIN
                RAISERROR ('Product not found', 16, 1);
            END;

        UPDATE orders.order_items
        SET product_uuid = @product_uuid,
            quantity     = @quantity,
            price        = (SELECT price FROM products.products WHERE product_uuid = @product_uuid)
        WHERE order_uuid = @order_uuid;

        COMMIT;

        SELECT * FROM orders.order_items WHERE order_uuid = @order_uuid;
    END TRY
    BEGIN CATCH
        ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO;

--
-- Delete order

CREATE OR ALTER PROC orders.sp_delete_order @order_uuid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT order_uuid FROM orders.orders WHERE order_uuid = @order_uuid)
            BEGIN
                RAISERROR ('Order not found', 16, 1);
            END;

        DELETE FROM orders.orders WHERE order_uuid = @order_uuid;

        COMMIT;

        SELECT 'Order deleted';
    END TRY
    BEGIN CATCH
        ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO;

--
-- disable order

CREATE OR ALTER PROC orders.sp_update_order_state @order_uuid UNIQUEIDENTIFIER,
                                                  @state_uuid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT order_uuid FROM orders.orders WHERE order_uuid = @order_uuid)
            BEGIN
                RAISERROR ('Order not found', 16, 1);
            END;

        UPDATE orders.orders
        SET state_uuid = @state_uuid
        WHERE order_uuid = @order_uuid;

        COMMIT;

        SELECT 'Order state updated';
    END TRY
    BEGIN CATCH
        ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO;

--
-- default data and examples

-- users procedures
EXEC users.sp_update_user '9AAD81EC-29AD-42CD-A4AA-2BA84444CF27', null, 'World', 'world@local.com', '02/12/2024';
EXEC users.sp_delete_user '9AAD81EC-29AD-42CD-A4AA-2BA84444CF27';

SELECT *
FROM users.users;

--
-- orders procedures
EXEC orders.sp_create_order 'EE4354E6-CFDA-4CB0-B6B6-460FAB869197', '0A0833E4-926E-455E-BBAB-1D5D01140020', 5;
EXEC orders.sp_update_order '351A9E06-CF66-4749-9D5C-FDF083D33C4D', '0A0833E4-926E-455E-BBAB-1D5D01140020', 10;
EXEC orders.sp_update_order_state '351A9E06-CF66-4749-9D5C-FDF083D33C4D', '92E3C1D7-95C3-49C0-AF6F-D33DFAB70DA6';
EXEC orders.sp_delete_order '351A9E06-CF66-4749-9D5C-FDF083D33C4D';

--
-- order view august - total amount of order

CREATE OR ALTER VIEW orders.vw_orders AS
SELECT *
FROM orders.orders
WHERE MONTH(created_at) = 12;

SELECT *
FROM orders.vw_orders;

-- +------------------------------------+------------------------------------+------+------------------------------------+-----------------------+-----------------------+
-- |order_uuid                          |user_uuid                           |amount|state_uuid                          |created_at             |updated_at             |
-- +------------------------------------+------------------------------------+------+------------------------------------+-----------------------+-----------------------+
-- |9329A51C-6FCF-40E5-8BAB-51288FCE65C4|EE4354E6-CFDA-4CB0-B6B6-460FAB869197|0.00  |F17A2A78-6AF9-4D0D-AB77-9DF053816EE2|2024-12-07 10:53:43.517|2024-12-07 10:53:43.517|
-- |0EFE5610-BB9B-4808-B842-A3B3E8181B23|EE4354E6-CFDA-4CB0-B6B6-460FAB869197|0.00  |F17A2A78-6AF9-4D0D-AB77-9DF053816EE2|2024-12-07 10:53:37.467|2024-12-07 10:53:37.467|
-- |BBA686F6-88D6-4ADC-A82A-E9237CF39EAD|EE4354E6-CFDA-4CB0-B6B6-460FAB869197|52.50 |F17A2A78-6AF9-4D0D-AB77-9DF053816EE2|2024-12-07 11:17:27.543|2024-12-07 11:17:27.543|
-- |351A9E06-CF66-4749-9D5C-FDF083D33C4D|EE4354E6-CFDA-4CB0-B6B6-460FAB869197|0.00  |F17A2A78-6AF9-4D0D-AB77-9DF053816EE2|2024-12-07 10:45:17.050|2024-12-07 10:45:17.050|
-- +------------------------------------+------------------------------------+------+------------------------------------+-----------------------+-----------------------+


--
-- order view - top 10 customers with more orders

CREATE OR ALTER VIEW orders.vw_top_customers AS
SELECT TOP 10 user_uuid,
              COUNT(order_uuid) AS orders
FROM orders.orders
GROUP BY user_uuid
ORDER BY orders DESC;

SELECT *
FROM orders.vw_top_customers;

-- +------------------------------------+------+
-- |user_uuid                           |orders|
-- +------------------------------------+------+
-- |EE4354E6-CFDA-4CB0-B6B6-460FAB869197|4     |
-- +------------------------------------+------+

--
-- order view - top 10 products with more orders

CREATE OR ALTER VIEW orders.vw_top_products AS
SELECT TOP 10 (SELECT title FROM products.products WHERE product_uuid = product_uuid) AS product,
              COUNT(order_item_uuid)                                                  AS orders
FROM orders.order_items
GROUP BY product_uuid
ORDER BY orders DESC;

SELECT *
FROM orders.vw_top_products;

-- +-------+------+
-- |product|orders|
-- +-------+------+
-- |Sugar  |4     |
-- +-------+------+

