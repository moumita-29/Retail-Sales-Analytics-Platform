-- ============================================================
-- Retail Sales Analytics Platform
-- File: 04_views.sql
-- Description: Reusable SQL Views for Power BI / reporting
-- ============================================================

-- ──────────────────────────────────────────────
-- VIEW 1: vw_sales_summary
-- Flat table of every order line with full context
-- ──────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_sales_summary AS
SELECT
    o.order_id,
    o.order_date,
    o.ship_date,
    o.ship_mode,
    DATEDIFF(o.ship_date, o.order_date)  AS days_to_ship,
    c.customer_id,
    c.customer_name,
    c.segment                            AS customer_segment,
    c.region                             AS customer_region,
    r.region_name,
    r.manager                            AS region_manager,
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    oi.quantity,
    oi.discount,
    oi.unit_price,
    oi.unit_cost,
    oi.revenue,
    oi.cost,
    oi.profit,
    ROUND(oi.profit / NULLIF(oi.revenue, 0) * 100, 2) AS profit_margin_pct
FROM orders      o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN regions     r  ON o.region_id   = r.region_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id;


-- ──────────────────────────────────────────────
-- VIEW 2: vw_monthly_kpis
-- Pre-aggregated monthly metrics for trend charts
-- ──────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_monthly_kpis AS
WITH base AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m')   AS month,
        revenue, cost, profit, order_id
    FROM vw_sales_summary
)
SELECT
    month,
    COUNT(DISTINCT order_id)               AS total_orders,
    ROUND(SUM(revenue), 2)                 AS total_revenue,
    ROUND(SUM(cost),    2)                 AS total_cost,
    ROUND(SUM(profit),  2)                 AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue),0) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(revenue) / COUNT(DISTINCT order_id), 2)    AS avg_order_value
FROM base
GROUP BY month
ORDER BY month;


-- ──────────────────────────────────────────────
-- VIEW 3: vw_product_performance
-- Product-level aggregation for Product Analysis page
-- ──────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    SUM(quantity)                                            AS units_sold,
    ROUND(SUM(revenue), 2)                                  AS total_revenue,
    ROUND(SUM(profit),  2)                                  AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)  AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(revenue) DESC)                AS revenue_rank,
    RANK() OVER (ORDER BY SUM(profit)  DESC)                AS profit_rank
FROM vw_sales_summary
GROUP BY product_id, product_name, category, sub_category;


-- ──────────────────────────────────────────────
-- VIEW 4: vw_customer_clv
-- Customer lifetime value & segmentation
-- ──────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_customer_clv AS
SELECT
    customer_id,
    customer_name,
    customer_segment,
    customer_region,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    SUM(quantity)                                            AS units_purchased,
    ROUND(SUM(revenue), 2)                                   AS lifetime_revenue,
    ROUND(SUM(profit),  2)                                   AS lifetime_profit,
    ROUND(SUM(revenue) / COUNT(DISTINCT order_id), 2)        AS avg_order_value,
    MIN(order_date)                                          AS first_order_date,
    MAX(order_date)                                          AS last_order_date,
    DATEDIFF(MAX(order_date), MIN(order_date))               AS customer_lifespan_days
FROM vw_sales_summary
GROUP BY customer_id, customer_name, customer_segment, customer_region;


-- ──────────────────────────────────────────────
-- VIEW 5: vw_regional_performance
-- Region-level performance for Regional Analysis page
-- ──────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_regional_performance AS
SELECT
    region_name,
    region_manager,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    COUNT(DISTINCT customer_id)                              AS unique_customers,
    ROUND(SUM(revenue), 2)                                   AS total_revenue,
    ROUND(SUM(profit),  2)                                   AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)   AS profit_margin_pct,
    ROUND(SUM(revenue) / COUNT(DISTINCT order_id), 2)        AS avg_order_value
FROM vw_sales_summary
GROUP BY region_name, region_manager;
