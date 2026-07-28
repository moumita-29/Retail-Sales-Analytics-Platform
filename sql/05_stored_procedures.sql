-- ============================================================
-- Retail Sales Analytics Platform
-- File: 05_stored_procedures.sql
-- Description: Stored Procedures for parameterized reporting
-- ============================================================

DELIMITER $$

-- ──────────────────────────────────────────────
-- SP 1: sp_sales_by_date_range
-- Returns full sales summary filtered by date range
-- Usage: CALL sp_sales_by_date_range('2024-01-01', '2024-06-30');
-- ──────────────────────────────────────────────
CREATE PROCEDURE sp_sales_by_date_range(
    IN p_start_date DATE,
    IN p_end_date   DATE
)
BEGIN
    SELECT
        order_id,
        order_date,
        customer_name,
        customer_segment,
        region_name,
        product_name,
        category,
        quantity,
        revenue,
        profit,
        profit_margin_pct
    FROM vw_sales_summary
    WHERE order_date BETWEEN p_start_date AND p_end_date
    ORDER BY order_date;
END$$


-- ──────────────────────────────────────────────
-- SP 2: sp_top_products
-- Returns top N products by revenue or profit
-- Usage: CALL sp_top_products('revenue', 5);
-- ──────────────────────────────────────────────
CREATE PROCEDURE sp_top_products(
    IN p_sort_by   VARCHAR(20),   -- 'revenue' or 'profit'
    IN p_limit     INT
)
BEGIN
    IF p_sort_by = 'profit' THEN
        SELECT *
        FROM vw_product_performance
        ORDER BY total_profit DESC
        LIMIT p_limit;
    ELSE
        SELECT *
        FROM vw_product_performance
        ORDER BY total_revenue DESC
        LIMIT p_limit;
    END IF;
END$$


-- ──────────────────────────────────────────────
-- SP 3: sp_region_comparison
-- Compare two regions across all KPIs
-- Usage: CALL sp_region_comparison('East', 'West');
-- ──────────────────────────────────────────────
CREATE PROCEDURE sp_region_comparison(
    IN p_region_a VARCHAR(50),
    IN p_region_b VARCHAR(50)
)
BEGIN
    SELECT *
    FROM vw_regional_performance
    WHERE region_name IN (p_region_a, p_region_b)
    ORDER BY total_revenue DESC;
END$$


-- ──────────────────────────────────────────────
-- SP 4: sp_customer_health_check
-- Flags at-risk customers (no orders in last N days)
-- Usage: CALL sp_customer_health_check(90);
-- ──────────────────────────────────────────────
CREATE PROCEDURE sp_customer_health_check(
    IN p_inactive_days INT
)
BEGIN
    WITH last_order AS (
        SELECT
            customer_id,
            MAX(order_date) AS last_order_date
        FROM orders
        GROUP BY customer_id
    )
    SELECT
        c.customer_id,
        c.customer_name,
        c.segment,
        c.region,
        lo.last_order_date,
        DATEDIFF(CURDATE(), lo.last_order_date) AS days_since_last_order,
        CASE
            WHEN DATEDIFF(CURDATE(), lo.last_order_date) > p_inactive_days
                THEN 'At Risk'
            ELSE 'Active'
        END AS customer_status
    FROM customers c
    JOIN last_order lo ON c.customer_id = lo.customer_id
    ORDER BY days_since_last_order DESC;
END$$


-- ──────────────────────────────────────────────
-- SP 5: sp_profit_analysis
-- Breakdown of what is driving or hurting profit
-- Usage: CALL sp_profit_analysis('category');
-- ──────────────────────────────────────────────
CREATE PROCEDURE sp_profit_analysis(
    IN p_group_by VARCHAR(20)  -- 'category', 'region', 'segment'
)
BEGIN
    CASE p_group_by
        WHEN 'category' THEN
            SELECT
                category                             AS dimension,
                ROUND(SUM(revenue), 2)               AS revenue,
                ROUND(SUM(profit),  2)               AS profit,
                ROUND(SUM(profit) / NULLIF(SUM(revenue),0) * 100, 2) AS margin_pct
            FROM vw_sales_summary
            GROUP BY category
            ORDER BY profit DESC;

        WHEN 'region' THEN
            SELECT
                region_name                          AS dimension,
                ROUND(SUM(revenue), 2)               AS revenue,
                ROUND(SUM(profit),  2)               AS profit,
                ROUND(SUM(profit) / NULLIF(SUM(revenue),0) * 100, 2) AS margin_pct
            FROM vw_sales_summary
            GROUP BY region_name
            ORDER BY profit DESC;

        WHEN 'segment' THEN
            SELECT
                customer_segment                     AS dimension,
                ROUND(SUM(revenue), 2)               AS revenue,
                ROUND(SUM(profit),  2)               AS profit,
                ROUND(SUM(profit) / NULLIF(SUM(revenue),0) * 100, 2) AS margin_pct
            FROM vw_sales_summary
            GROUP BY customer_segment
            ORDER BY profit DESC;

        ELSE
            SELECT 'Invalid group_by value. Use: category, region, or segment' AS error_message;
    END CASE;
END$$

DELIMITER ;
