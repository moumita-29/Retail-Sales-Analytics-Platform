-- ============================================================
-- Retail Sales Analytics Platform
-- File: 02_sample_data.sql
-- Description: Sample seed data for testing queries
-- ============================================================

-- Regions
INSERT INTO regions (region_name, country, manager) VALUES
('North',  'USA', 'Alice Johnson'),
('South',  'USA', 'Bob Martinez'),
('East',   'USA', 'Carol Smith'),
('West',   'USA', 'David Lee'),
('Central','USA', 'Eva Brown');

-- Customers
INSERT INTO customers (customer_name, email, phone, region, segment, join_date) VALUES
('Acme Corp',       'acme@email.com',    '555-0101', 'East',    'Corporate',   '2020-01-15'),
('Global Traders',  'global@email.com',  '555-0102', 'West',    'Corporate',   '2020-03-22'),
('Smith Household', 'smith@email.com',   '555-0103', 'North',   'Consumer',    '2021-05-10'),
('TechStart LLC',   'tech@email.com',    '555-0104', 'South',   'Home Office', '2019-11-01'),
('Retail Plus',     'retail@email.com',  '555-0105', 'Central', 'Corporate',   '2022-07-19'),
('Green Leaf Co.',  'green@email.com',   '555-0106', 'East',    'Consumer',    '2021-02-28'),
('Metro Supplies',  'metro@email.com',   '555-0107', 'West',    'Corporate',   '2020-09-14'),
('Home Basics',     'home@email.com',    '555-0108', 'North',   'Consumer',    '2023-01-05');

-- Products
INSERT INTO products (product_name, category, sub_category, unit_cost, unit_price) VALUES
('Office Chair Pro',      'Furniture',    'Chairs',       85.00,  249.99),
('Standing Desk',         'Furniture',    'Tables',       210.00, 549.99),
('Laptop Stand',          'Technology',   'Accessories',  18.50,  59.99),
('Wireless Keyboard',     'Technology',   'Peripherals',  22.00,  79.99),
('USB-C Hub 7-Port',      'Technology',   'Accessories',  14.00,  44.99),
('File Cabinet 3-Drawer', 'Furniture',    'Storage',      65.00,  189.99),
('Printer Paper Ream',    'Office Supplies','Paper',       4.50,  12.99),
('Ballpoint Pens (12pk)', 'Office Supplies','Writing',    2.00,   7.99),
('Monitor 27" 4K',        'Technology',   'Monitors',    280.00, 699.99),
('Ergonomic Mouse',       'Technology',   'Peripherals',  12.00,  39.99);

-- Orders
INSERT INTO orders (order_date, ship_date, ship_mode, customer_id, region_id) VALUES
('2024-01-10','2024-01-14','Standard Class', 1, 3),
('2024-01-18','2024-01-20','First Class',    2, 4),
('2024-02-05','2024-02-08','Second Class',   3, 1),
('2024-02-20','2024-02-22','Standard Class', 4, 2),
('2024-03-03','2024-03-06','First Class',    5, 5),
('2024-03-15','2024-03-17','Standard Class', 6, 3),
('2024-04-01','2024-04-04','Same Day',       7, 4),
('2024-04-22','2024-04-25','Second Class',   1, 3),
('2024-05-10','2024-05-13','Standard Class', 2, 4),
('2024-05-28','2024-05-30','First Class',    8, 1),
('2024-06-12','2024-06-14','Standard Class', 3, 1),
('2024-07-01','2024-07-04','Second Class',   4, 2);

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, discount, unit_price, unit_cost) VALUES
(1,  1, 4, 0.10, 249.99, 85.00),
(1,  7,20, 0.05,  12.99,  4.50),
(2,  9, 2, 0.00, 699.99,280.00),
(2,  3, 5, 0.10,  59.99, 18.50),
(3,  8,50, 0.00,   7.99,  2.00),
(3,  5,10, 0.05,  44.99, 14.00),
(4,  2, 1, 0.00, 549.99,210.00),
(4, 10, 3, 0.00,  39.99, 12.00),
(5,  1, 6, 0.15, 249.99, 85.00),
(5,  4, 6, 0.10,  79.99, 22.00),
(6,  6, 2, 0.00, 189.99, 65.00),
(7,  9, 1, 0.20, 699.99,280.00),
(8,  3,10, 0.05,  59.99, 18.50),
(9,  7,30, 0.00,  12.99,  4.50),
(10, 1, 2, 0.00, 249.99, 85.00),
(10, 2, 1, 0.10, 549.99,210.00),
(11, 8,40, 0.00,   7.99,  2.00),
(12, 5,15, 0.05,  44.99, 14.00);
