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
        FILENAME = 'C:\Web360\web360_data.mdf',
        SIZE = 10,
        MAXSIZE = 50,
        FILEGROWTH = 5)
    LOG ON
    ( NAME = web360_log,
        FILENAME = 'C:\Web360\web360_log.ldf',
        SIZE = 5 MB,
        MAXSIZE = 25 MB,
        FILEGROWTH = 5 MB );

USE web360;

--
-- system

CREATE SCHEMA system;

CREATE TABLE system.roles
(
    role_uuid  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code       NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label      NVARCHAR(50) NOT NULL,
    is_active  BIT          NOT NULL        DEFAULT 1,
    created_at DATETIME     NOT NULL        DEFAULT GETDATE(),
    updated_at DATETIME     NOT NULL        DEFAULT GETDATE()
);

CREATE TABLE system.states
(
    state_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code       NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label      NVARCHAR(50) NOT NULL,
    created_at DATETIME     NOT NULL        DEFAULT GETDATE(),
    updated_at DATETIME     NOT NULL        DEFAULT GETDATE()
);

--
-- users

CREATE SCHEMA users;

CREATE TABLE users.users
(
    user_uuid   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    first_name  NVARCHAR(50)  NOT NULL,
    last_name   NVARCHAR(50)  NOT NULL,
    customer_id NVARCHAR(50),
    email       NVARCHAR(100) NOT NULL,
    birth_date  DATE,
    created_at  DATETIME      NOT NULL       DEFAULT GETDATE(),
    updated_at  DATETIME      NOT NULL       DEFAULT GETDATE(),
    CONSTRAINT uc_email UNIQUE (email),
    CONSTRAINT uc_customer_id UNIQUE (email, customer_id)
);

CREATE TABLE users.passwords
(
    credential_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid       UNIQUEIDENTIFIER NOT NULL,
    hash            NVARCHAR(100)    NOT NULL,
    salt            NVARCHAR(100)    NOT NULL,
    created_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    FOREIGN KEY (user_uuid) REFERENCES users.users (user_uuid) ON DELETE CASCADE,
    CONSTRAINT uc_user_password UNIQUE (user_uuid)
);

CREATE TABLE users.users_roles
(
    user_role_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid      UNIQUEIDENTIFIER NOT NULL,
    role_uuid      UNIQUEIDENTIFIER NOT NULL,
    created_at     DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at     DATETIME         NOT NULL    DEFAULT GETDATE(),
    FOREIGN KEY (user_uuid) REFERENCES users.users (user_uuid) ON DELETE CASCADE,
    FOREIGN KEY (role_uuid) REFERENCES system.roles (role_uuid) ON DELETE CASCADE,
    CONSTRAINT uc_user_role UNIQUE (user_uuid, role_uuid)
);

--
-- Create user
-- Documentation: https://learn.microsoft.com/es-es/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-ver16

CREATE OR ALTER PROC users.sp_create_user @first_name NVARCHAR(50),
                                          @last_name NVARCHAR(50),
                                          @customer_id NVARCHAR(50),
                                          @email NVARCHAR(100),
                                          @password NVARCHAR(100),
                                          @salt NVARCHAR(100),
                                          @birth_date DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE
                              (
                                  user_uuid UNIQUEIDENTIFIER
                              );

        INSERT INTO users.users (first_name, last_name, customer_id, email, birth_date)
        OUTPUT INSERTED.user_uuid INTO @InsertedRows
        VALUES (@first_name, @last_name, @customer_id, @email, @birth_date);

        INSERT INTO users.passwords (user_uuid, hash, salt)
        VALUES ((SELECT user_uuid FROM @InsertedRows), @password, @salt);

        INSERT INTO users.users_roles (user_uuid, role_uuid)
        VALUES ((SELECT user_uuid FROM @InsertedRows), (SELECT role_uuid FROM system.roles WHERE code = 'user'));

        COMMIT;

        SELECT user_uuid FROM @InsertedRows;
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
-- Update user

CREATE OR ALTER PROC users.sp_update_user @user_uuid UNIQUEIDENTIFIER,
                                          @first_name NVARCHAR(50),
                                          @last_name NVARCHAR(50),
                                          @email NVARCHAR(100),
                                          @birth_date DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT user_uuid FROM users.users WHERE user_uuid = @user_uuid)
            BEGIN
                RAISERROR ('User not found', 16, 1);
            END;

        UPDATE users.users
        SET first_name = coalesce(@first_name, first_name),
            last_name  = coalesce(@last_name, last_name),
            email      = coalesce(@email, email),
            birth_date = coalesce(@birth_date, birth_date)
        WHERE user_uuid = @user_uuid;

        COMMIT;

        SELECT * FROM users.users WHERE user_uuid = @user_uuid;
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
-- Delete user

CREATE OR ALTER PROC users.sp_delete_user @user_uuid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT user_uuid FROM users.users WHERE user_uuid = @user_uuid)
            BEGIN
                RAISERROR ('User not found', 16, 1);
            END;

        DELETE FROM users.users WHERE user_uuid = @user_uuid;

        COMMIT;

        SELECT 'User deleted';
    END TRY
    BEGIN CATCH
        ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END
GO;

--
-- products

CREATE SCHEMA products;

CREATE TABLE products.categories
(
    category_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    code          NVARCHAR(50)     NOT NULL UNIQUE CHECK (LEN(code) > 0),
    label         NVARCHAR(50)     NOT NULL,
    state_uuid    UNIQUEIDENTIFIER NOT NULL,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    FOREIGN KEY (state_uuid) REFERENCES system.states (state_uuid) ON DELETE CASCADE
);

CREATE TABLE products.products
(
    product_uuid  UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    category_uuid UNIQUEIDENTIFIER NOT NULL,
    title         NVARCHAR(100)    NOT NULL,
    description   NVARCHAR(255)    NOT NULL,
    price         DECIMAL(10, 2)   NOT NULL,
    state_uuid    UNIQUEIDENTIFIER NOT NULL,
    stock         INT              NOT NULL    DEFAULT 0,
    created_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at    DATETIME         NOT NULL    DEFAULT GETDATE(),
    FOREIGN KEY (category_uuid) REFERENCES products.categories (category_uuid) ON DELETE CASCADE
);

--
-- Create product
CREATE OR ALTER PROC products.sp_create_product @category_uuid UNIQUEIDENTIFIER,
                                                @title NVARCHAR(100),
                                                @description NVARCHAR(255),
                                                @price DECIMAL(10, 2),
                                                @stock INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE
                              (
                                  product_uuid UNIQUEIDENTIFIER
                              );
        INSERT INTO products.products (category_uuid, title, description, state_uuid, price, stock)
        OUTPUT INSERTED.product_uuid INTO @InsertedRows
        VALUES (@category_uuid, @title, @description, (SELECT state_uuid FROM system.states WHERE code = 'active'),
                @price, @stock);
        COMMIT;

        SELECT product_uuid FROM @InsertedRows;
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
-- Update product

CREATE OR ALTER PROC products.sp_update_product @product_uuid UNIQUEIDENTIFIER,
                                                @title NVARCHAR(100),
                                                @description NVARCHAR(255),
                                                @price DECIMAL(10, 2),
                                                @stock INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT product_uuid FROM products.products WHERE product_uuid = @product_uuid)
            BEGIN
                RAISERROR ('Product not found', 16, 1);
            END;

        UPDATE products.products
        SET title       = coalesce(@title, title),
            description = coalesce(@description, description),
            price       = coalesce(@price, price),
            stock       = coalesce(@stock, stock)
        WHERE product_uuid = @product_uuid;

        COMMIT;

        SELECT * FROM products.products WHERE product_uuid = @product_uuid;
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
-- Delete product

CREATE OR ALTER PROC products.sp_delete_product @product_uuid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT product_uuid FROM products.products WHERE product_uuid = @product_uuid)
            BEGIN
                RAISERROR ('Product not found', 16, 1);
            END;

        DELETE FROM products.products WHERE product_uuid = @product_uuid;

        COMMIT;

        SELECT 'Product deleted';
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
-- disable product

CREATE OR ALTER PROC products.sp_update_product_state @product_uuid UNIQUEIDENTIFIER,
                                                      @state_uuid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT product_uuid FROM products.products WHERE product_uuid = @product_uuid)
            BEGIN
                RAISERROR ('Product not found', 16, 1);
            END;

        UPDATE products.products
        SET state_uuid = @state_uuid
        WHERE product_uuid = @product_uuid;

        COMMIT;

        SELECT 'Product state updated';
    END TRY BEGIN CATCH
        ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO;

--
-- orders

CREATE SCHEMA orders;

CREATE TABLE orders.orders
(
    order_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_uuid  UNIQUEIDENTIFIER NOT NULL,
    amount     DECIMAL(10, 2)   NOT NULL,
    state_uuid UNIQUEIDENTIFIER NOT NULL,
    created_at DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at DATETIME         NOT NULL    DEFAULT GETDATE(),
    FOREIGN KEY (user_uuid) REFERENCES users.users (user_uuid) ON DELETE CASCADE
);

CREATE TABLE orders.order_items
(
    order_item_uuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    order_uuid      UNIQUEIDENTIFIER NOT NULL,
    product_uuid    UNIQUEIDENTIFIER NOT NULL,
    quantity        INT              NOT NULL,
    price           DECIMAL(10, 2)   NOT NULL,
    total           DECIMAL(10, 2)   NOT NULL,
    created_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    updated_at      DATETIME         NOT NULL    DEFAULT GETDATE(),
    FOREIGN KEY (order_uuid) REFERENCES orders.orders (order_uuid) ON DELETE CASCADE,
    FOREIGN KEY (product_uuid) REFERENCES products.products (product_uuid) ON DELETE CASCADE
);

CREATE FUNCTION orders.fn_calculate_total(@quantity INT, @price DECIMAL(10, 2))
    RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @quantity * @price;
END;

CREATE TRIGGER orders.trg_calculate_total
    ON orders.order_items
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    UPDATE orders.order_items
    SET total = orders.fn_calculate_total(quantity, price)
    WHERE order_item_uuid IN (SELECT order_item_uuid FROM inserted);
END;
GO;

--
-- Create order
CREATE OR ALTER PROC orders.sp_create_order @user_uuid UNIQUEIDENTIFIER,
                                            @product_uuid UNIQUEIDENTIFIER,
                                            @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InsertedRows TABLE
                              (
                                  order_uuid UNIQUEIDENTIFIER
                              );

        INSERT INTO orders.orders (user_uuid, amount, state_uuid)
        OUTPUT INSERTED.order_uuid INTO @InsertedRows
        VALUES (@user_uuid, 0, (SELECT state_uuid FROM system.states WHERE code = 'pending'));

        INSERT INTO orders.order_items (order_uuid, product_uuid, quantity, price, total)
        VALUES ((SELECT order_uuid FROM @InsertedRows), @product_uuid, @quantity,
                (SELECT price FROM products.products WHERE product_uuid = @product_uuid), 0);

        UPDATE products.products
        SET stock = stock - @quantity
        WHERE product_uuid = @product_uuid;

        UPDATE orders.orders
        SET amount = (SELECT SUM(total)
                      FROM orders.order_items
                      WHERE order_uuid = (SELECT order_uuid FROM @InsertedRows))
        WHERE order_uuid = (SELECT order_uuid FROM @InsertedRows);

        COMMIT;

        SELECT order_uuid FROM @InsertedRows;
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

-- roles
INSERT INTO system.roles (code, label)
VALUES ('admin', 'Administrator'),
       ('user', 'User');
SELECT *
FROM system.roles
WHERE is_active = 1;

-- states
INSERT INTO system.states (code, label)
VALUES ('active', 'Activo'),
       ('inactive', 'Inactivo'),
       ('deleted', 'Eliminado'),
       ('disabled', 'Deshabilitado'),
       ('blocked', 'Bloqueado'),
       ('pending', 'Pendiente'),
       ('approved', 'Aprobado'),
       ('rejected', 'Rechazado'),
       ('canceled', 'Cancelado'),
       ('completed', 'Completado'),
       ('expired', 'Expirado');
SELECT *
FROM system.states;

-- users procedures
EXEC users.sp_create_user 'Hello', 'World', 'C12348', 'test@local.com', 'asldkasd91283j', '10', '02/12/2024';
EXEC users.sp_update_user '9AAD81EC-29AD-42CD-A4AA-2BA84444CF27', null, 'World', 'world@local.com', '02/12/2024';
EXEC users.sp_delete_user '9AAD81EC-29AD-42CD-A4AA-2BA84444CF27';

SELECT *
FROM users.users;

-- products categories
INSERT INTO products.categories (code, label, state_uuid)
VALUES ('sugar', N'Azúcar', (SELECT state_uuid FROM system.states WHERE code = 'active')),
       ('rice', 'Arroz', (SELECT state_uuid FROM system.states WHERE code = 'active')),
       ('salt', 'Sal', (SELECT state_uuid FROM system.states WHERE code = 'active'));
SELECT *
FROM products.categories
WHERE state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active');

-- products
EXEC products.sp_create_product '965C8C46-1936-4EB9-B2FA-3C55BD720799', 'Sugar', 'Sugar 1kg', 10.50, 100;
EXEC products.sp_update_product '3F22091F-5AA0-4B85-942C-77E66B2E4F4A', 'Sugar', 'Sugar 1kg', 10.50, 50;
EXEC products.sp_update_product_state '3F22091F-5AA0-4B85-942C-77E66B2E4F4A', '92E3C1D7-95C3-49C0-AF6F-D33DFAB70DA6';
EXEC products.sp_delete_product '3F22091F-5AA0-4B85-942C-77E66B2E4F4A';

--
-- product view

CREATE OR ALTER VIEW products.vw_products AS
SELECT *
FROM products.products
WHERE state_uuid = (SELECT state_uuid FROM system.states WHERE code = 'active')
  AND stock > 0;

SELECT *
FROM products.vw_products;

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
