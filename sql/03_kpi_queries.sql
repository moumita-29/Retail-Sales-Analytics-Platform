-- ============================================================
-- Retail Sales Analytics Platform
-- File: 03_kpi_queries.sql
-- Description: Core KPI queries using JOINs, CTEs, Window Functions
-- ============================================================

-- ──────────────────────────────────────────────
-- KPI 1: Total Sales, Revenue, Cost & Profit
-- ──────────────────────────────────────────────
SELECT
    COUNT(DISTINCT o.order_id)            AS total_orders,
    SUM(oi.quantity)                      AS total_units_sold,
    ROUND(SUM(oi.revenue), 2)             AS total_revenue,
    ROUND(SUM(oi.cost), 2)                AS total_cost,
    ROUND(SUM(oi.profit), 2)              AS total_profit,
    ROUND(SUM(oi.profit) / NULLIF(SUM(oi.revenue),0) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;


-- ──────────────────────────────────────────────
-- KPI 2: Average Order Value (AOV)
-- ──────────────────────────────────────────────
SELECT
    ROUND(SUM(oi.revenue) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;


-- ──────────────────────────────────────────────
-- KPI 3: Monthly Revenue & Growth Rate
--        (Window Function: LAG)
-- ──────────────────────────────────────────────
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')   AS month,
        ROUND(SUM(oi.revenue), 2)            AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                         AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100,
    2)                                                         AS growth_pct
FROM monthly_revenue
ORDER BY month;


-- ──────────────────────────────────────────────
-- KPI 4: Top 10 Customers by Revenue
-- ──────────────────────────────────────────────
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    c.region,
    ROUND(SUM(oi.revenue), 2)  AS total_revenue,
    ROUND(SUM(oi.profit),  2)  AS total_profit,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders     o  ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id   = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.segment, c.region
ORDER BY total_revenue DESC
LIMIT 10;


-- ──────────────────────────────────────────────
-- KPI 5: Customer Retention (Repeat Buyers)
-- ──────────────────────────────────────────────
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    COUNT(*)                                           AS total_customers,
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
    2)                                                 AS retention_rate_pct
FROM customer_orders;


-- ──────────────────────────────────────────────
-- KPI 6: Product Performance — Revenue & Rank
--        (Window Function: RANK)
-- ──────────────────────────────────────────────
WITH product_perf AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.sub_category,
        ROUND(SUM(oi.revenue), 2)  AS total_revenue,
        ROUND(SUM(oi.profit),  2)  AS total_profit,
        SUM(oi.quantity)           AS units_sold,
        ROUND(SUM(oi.profit) / NULLIF(SUM(oi.revenue),0) * 100, 2) AS margin_pct
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.sub_category
)
SELECT
    *,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_profit  DESC) AS profit_rank
FROM product_perf
ORDER BY revenue_rank;


-- ──────────────────────────────────────────────
-- KPI 7: Regional Sales Analysis
--        (JOIN + GROUP BY)
-- ──────────────────────────────────────────────
SELECT
    r.region_name,
    r.manager,
    COUNT(DISTINCT o.order_id)             AS total_orders,
    COUNT(DISTINCT o.customer_id)          AS unique_customers,
    ROUND(SUM(oi.revenue), 2)              AS total_revenue,
    ROUND(SUM(oi.profit),  2)              AS total_profit,
    ROUND(SUM(oi.profit) / NULLIF(SUM(oi.revenue),0) * 100, 2) AS profit_margin_pct
FROM regions     r
JOIN orders      o  ON r.region_id    = o.region_id
JOIN order_items oi ON o.order_id     = oi.order_id
GROUP BY r.region_id, r.region_name, r.manager
ORDER BY total_revenue DESC;


-- ──────────────────────────────────────────────
-- KPI 8: Customer Lifetime Value (CLV)
--        (CTE + Window Function: SUM OVER)
-- ──────────────────────────────────────────────
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.segment,
        ROUND(SUM(oi.revenue), 2) AS clv
    FROM customers   c
    JOIN orders      o  ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.segment
)
SELECT
    *,
    ROUND(clv / SUM(clv) OVER () * 100, 2) AS pct_of_total_revenue,
    RANK() OVER (ORDER BY clv DESC)         AS clv_rank
FROM customer_revenue
ORDER BY clv DESC;
