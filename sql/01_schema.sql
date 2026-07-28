-- ============================================================
-- Retail Sales Analytics Platform
-- File: 01_schema.sql
-- Description: Database schema creation
-- ============================================================

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id     INT PRIMARY KEY AUTO_INCREMENT,
    customer_name   VARCHAR(150) NOT NULL,
    email           VARCHAR(150) UNIQUE,
    phone           VARCHAR(20),
    region          VARCHAR(50),
    segment         VARCHAR(50),          -- e.g. Consumer, Corporate, Home Office
    join_date       DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    product_id      INT PRIMARY KEY AUTO_INCREMENT,
    product_name    VARCHAR(200) NOT NULL,
    category        VARCHAR(100),
    sub_category    VARCHAR(100),
    unit_cost       DECIMAL(10,2),
    unit_price      DECIMAL(10,2),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Regions Table
CREATE TABLE IF NOT EXISTS regions (
    region_id       INT PRIMARY KEY AUTO_INCREMENT,
    region_name     VARCHAR(50) NOT NULL,
    country         VARCHAR(100),
    manager         VARCHAR(150)
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    order_id        INT PRIMARY KEY AUTO_INCREMENT,
    order_date      DATE NOT NULL,
    ship_date       DATE,
    ship_mode       VARCHAR(50),
    customer_id     INT NOT NULL,
    region_id       INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (region_id)   REFERENCES regions(region_id)
);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    item_id         INT PRIMARY KEY AUTO_INCREMENT,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    discount        DECIMAL(5,2) DEFAULT 0.00,   -- discount percentage (0-1)
    unit_price      DECIMAL(10,2) NOT NULL,
    unit_cost       DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- Derived / computed columns as generated columns (MySQL 5.7+)
-- ============================================================
ALTER TABLE order_items
    ADD COLUMN revenue      DECIMAL(12,2) GENERATED ALWAYS AS
                            (quantity * unit_price * (1 - discount)) STORED,
    ADD COLUMN cost         DECIMAL(12,2) GENERATED ALWAYS AS
                            (quantity * unit_cost) STORED,
    ADD COLUMN profit       DECIMAL(12,2) GENERATED ALWAYS AS
                            (quantity * unit_price * (1 - discount) - quantity * unit_cost) STORED;
    
