
CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

-- ─────────────────────────────────────────
-- 1. CUSTOMERS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    customer_id   INT           PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NOT NULL,
    email         VARCHAR(100)  UNIQUE NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(50),
    state         VARCHAR(50),
    region        VARCHAR(20),          -- North / South / East / West
    signup_date   DATE          NOT NULL
);

-- ─────────────────────────────────────────
-- 2. PRODUCT CATEGORIES  (lookup)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
    category_id   INT           PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50)   NOT NULL,
    department    VARCHAR(50)
);

-- ─────────────────────────────────────────
-- 3. PRODUCTS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    product_id    INT           PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(100)  NOT NULL,
    category_id   INT           NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    unit_cost     DECIMAL(10,2) NOT NULL,
    supplier      VARCHAR(100),
    stock_qty     INT           DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ─────────────────────────────────────────
-- 4. ORDERS  (header)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    order_id      INT           PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT           NOT NULL,
    order_date    DATE          NOT NULL,
    ship_date     DATE,
    ship_mode     VARCHAR(30),           -- Standard / Express / Same-Day
    payment_mode  VARCHAR(30),           -- Card / UPI / COD / Net Banking
    order_status  VARCHAR(20)   DEFAULT 'Delivered',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ─────────────────────────────────────────
-- 5. ORDER ITEMS  (line-level detail)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    item_id       INT           PRIMARY KEY AUTO_INCREMENT,
    order_id      INT           NOT NULL,
    product_id    INT           NOT NULL,
    quantity      INT           NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    discount      DECIMAL(4,2)  DEFAULT 0.00,   -- e.g. 0.10 = 10 %
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ─────────────────────────────────────────
-- 6. RETURNS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS returns (
    return_id     INT           PRIMARY KEY AUTO_INCREMENT,
    order_id      INT           NOT NULL,
    product_id    INT           NOT NULL,
    return_date   DATE          NOT NULL,
    quantity      INT           NOT NULL,
    reason        VARCHAR(100),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ─────────────────────────────────────────
-- Handy view: flat sales fact table
-- (used heavily in Power BI)
-- ─────────────────────────────────────────
CREATE OR REPLACE VIEW vw_sales_fact AS
SELECT
    o.order_id,
    o.order_date,
    YEAR(o.order_date)                                  AS order_year,
    MONTH(o.order_date)                                 AS order_month,
    MONTHNAME(o.order_date)                             AS month_name,
    QUARTER(o.order_date)                               AS quarter,
    o.ship_mode,
    o.payment_mode,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)              AS customer_name,
    c.city,
    c.state,
    c.region,
    p.product_id,
    p.product_name,
    cat.category_name,
    cat.department,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    ROUND(oi.quantity * oi.unit_price * (1 - oi.discount), 2)  AS revenue,
    ROUND(oi.quantity * (oi.unit_price - p.unit_cost) * (1 - oi.discount), 2) AS profit
FROM orders        o
JOIN customers     c   ON o.customer_id  = c.customer_id
JOIN order_items   oi  ON o.order_id     = oi.order_id
JOIN products      p   ON oi.product_id  = p.product_id
JOIN categories    cat ON p.category_id  = cat.category_id;

SELECT 'Schema created successfully!' AS status;
