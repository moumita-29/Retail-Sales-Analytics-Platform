-- ============================================================
-- Retail Sales Analytics Platform
-- File: 06_business_insights.sql
-- Description: Advanced SQL answering business questions
-- ============================================================

-- ──────────────────────────────────────────────
-- Q1: Why did profits decrease?
-- Identify categories / products with declining margins
-- ──────────────────────────────────────────────
WITH monthly_category AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        category,
        ROUND(SUM(profit), 2)            AS profit,
        ROUND(SUM(profit) / NULLIF(SUM(revenue),0) * 100, 2) AS margin_pct
    FROM vw_sales_summary
    GROUP BY DATE_FORMAT(order_date, '%Y-%m'), category
),
with_lag AS (
    SELECT
        *,
        LAG(profit)     OVER (PARTITION BY category ORDER BY month) AS prev_profit,
        LAG(margin_pct) OVER (PARTITION BY category ORDER BY month) AS prev_margin
    FROM monthly_category
)
SELECT
    month,
    category,
    profit,
    prev_profit,
    ROUND(profit - prev_profit, 2)  AS profit_change,
    margin_pct,
    prev_margin,
    ROUND(margin_pct - prev_margin, 2) AS margin_change_pp
FROM with_lag
WHERE prev_profit IS NOT NULL
  AND profit < prev_profit
ORDER BY profit_change;


-- ──────────────────────────────────────────────
-- Q2: Which products should be discontinued?
-- Low revenue, negative/low margin, low sales volume
-- ──────────────────────────────────────────────
WITH product_stats AS (
    SELECT
        product_id,
        product_name,
        category,
        sub_category,
        ROUND(SUM(revenue), 2)                                  AS total_revenue,
        ROUND(SUM(profit),  2)                                   AS total_profit,
        SUM(quantity)                                            AS units_sold,
        ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)  AS margin_pct
    FROM vw_sales_summary
    GROUP BY product_id, product_name, category, sub_category
),
units_ranked AS (
    SELECT units_sold,
           ROW_NUMBER() OVER (ORDER BY units_sold) AS rn,
           COUNT(*) OVER ()                         AS total_cnt
    FROM product_stats
),
p25_units AS (
    SELECT AVG(units_sold) AS units_p25
    FROM units_ranked
    WHERE rn IN (FLOOR((total_cnt + 1) / 4), CEIL((total_cnt + 1) / 4))
)
SELECT
    ps.*,
    CASE
        WHEN ps.margin_pct   < 10  THEN 'Low Margin'
        WHEN ps.total_profit < 0   THEN 'Losing Money'
        WHEN ps.units_sold   < p.units_p25 AND ps.margin_pct < 20 THEN 'Low Volume + Low Margin'
        ELSE NULL
    END AS discontinue_reason
FROM product_stats ps
CROSS JOIN p25_units p
WHERE ps.margin_pct < 10
   OR ps.total_profit < 0
   OR (ps.units_sold < p.units_p25 AND ps.margin_pct < 20)
ORDER BY ps.margin_pct;


-- ──────────────────────────────────────────────
-- Q3: Which region deserves more investment?
-- High growth rate but lower current revenue
-- ──────────────────────────────────────────────
WITH region_monthly AS (
    SELECT
        region_name,
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        ROUND(SUM(revenue), 2)           AS revenue
    FROM vw_sales_summary
    GROUP BY region_name, DATE_FORMAT(order_date, '%Y-%m')
),
with_growth AS (
    SELECT
        *,
        LAG(revenue) OVER (PARTITION BY region_name ORDER BY month) AS prev_revenue,
        ROUND(
            (revenue - LAG(revenue) OVER (PARTITION BY region_name ORDER BY month))
            / NULLIF(LAG(revenue) OVER (PARTITION BY region_name ORDER BY month), 0) * 100,
        2) AS growth_pct
    FROM region_monthly
),
avg_growth AS (
    SELECT
        region_name,
        ROUND(AVG(growth_pct), 2)  AS avg_monthly_growth_pct,
        ROUND(SUM(revenue), 2)     AS total_revenue
    FROM with_growth
    WHERE growth_pct IS NOT NULL
    GROUP BY region_name
)
SELECT
    *,
    RANK() OVER (ORDER BY avg_monthly_growth_pct DESC) AS growth_rank,
    RANK() OVER (ORDER BY total_revenue DESC)           AS revenue_rank
FROM avg_growth
ORDER BY growth_rank;


-- ──────────────────────────────────────────────
-- Q4: Which customers generate the highest lifetime value?
-- CLV with recency, frequency, monetary (RFM) scoring
-- ──────────────────────────────────────────────
WITH rfm_base AS (
    SELECT
        customer_id,
        customer_name,
        customer_segment,
        DATEDIFF(CURDATE(), MAX(order_date))       AS recency_days,
        COUNT(DISTINCT order_id)                    AS frequency,
        ROUND(SUM(revenue), 2)                      AS monetary
    FROM vw_sales_summary
    GROUP BY customer_id, customer_name, customer_segment
),
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,  -- lower days = higher score
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary   DESC)    AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    customer_name,
    customer_segment,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score)    AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customer'
        WHEN (r_score + f_score + m_score) >=  7 THEN 'Potential Loyalist'
        WHEN (r_score + f_score + m_score) >=  4 THEN 'At Risk'
        ELSE                                           'Lost'
    END AS customer_tier
FROM rfm_scored
ORDER BY rfm_total DESC;
