# 🛒 Retail Sales Analytics Platform

> **A complete, end-to-end data analytics solution** that transforms raw retail transaction data into actionable business intelligence — built with SQL, Python, Power BI, and Excel.

![Status](https://img.shields.io/badge/Status-Complete-39D353?style=flat-square)
![SQL](https://img.shields.io/badge/SQL-MySQL%208.0-4361EE?style=flat-square&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.14-7209B7?style=flat-square&logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-6%20Pages-F72585?style=flat-square&logo=powerbi&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-Automated%20Report-4CC9F0?style=flat-square&logo=microsoft-excel&logoColor=white)

---

## 📌 Problem Statement

A retail company wants to **understand its sales performance and improve profitability**.

Rather than just displaying charts, this platform directly answers **real business questions**:

| ❓ Business Question | 📊 Answered In |
|---------------------|----------------|
| Why did profits decrease? | `06_business_insights.sql` + Profit Analysis dashboard |
| Which products should be discontinued? | `06_business_insights.sql` + Product Performance dashboard |
| Which region deserves more investment? | `06_business_insights.sql` + Regional Analysis dashboard |
| Which customers generate the highest lifetime value? | RFM Analysis + Customer Analysis dashboard |

---

## 🧰 Tech Stack

| Technology | Version | Role |
|-----------|---------|------|
| **MySQL** | 8.0.46 | Relational database — schema, queries, views, stored procedures |
| **SQL** | — | JOINs, CTEs, Window Functions, Views, Stored Procedures |
| **Python** | 3.14 | Exploratory data analysis, chart generation, Excel automation |
| **Power BI Desktop** | Latest | 6-page interactive business intelligence dashboard |
| **Excel** | — | Formatted multi-sheet report via Python automation |

---

## 📁 Project Structure

```
Retail-Sales-Analytics-Platform/
│
├── 📄 README.md                          ← Project documentation (this file)
├── 📄 RUN_ALL.bat                         ← One-click automation runner
├── 📄 .gitignore
│
├── 📂 sql/
│   ├── 01_schema.sql                     ← Database schema (5 tables)
│   ├── 02_sample_data.sql                ← Seed data (customers, products, orders)
│   ├── 03_kpi_queries.sql                ← 8 KPI queries (JOINs + CTEs + Window Functions)
│   ├── 04_views.sql                      ← 5 reusable views for reporting
│   ├── 05_stored_procedures.sql          ← 5 parameterized stored procedures
│   └── 06_business_insights.sql         ← 4 strategic business insight queries (RFM, CLV)
│
├── 📂 python/
│   ├── analysis.py                       ← EDA script: 6 dark-themed insight charts
│   ├── export_to_excel.py                ← Automated Excel workbook generator (5 sheets)
│   └── requirements.txt                  ← Python dependencies
│
├── 📂 powerbi/
│   ├── Executive Overview.pbix           ← Page 1: High-level KPI snapshot
│   ├── Sales Analysis.pbix               ← Page 2: Revenue trends & order patterns
│   ├── Customer Analysis.pbix            ← Page 3: CLV, RFM, retention analysis
│   ├── Product Performance.pbix          ← Page 4: Product rankings & margin heatmap
│   ├── Regional Analysis.pbix            ← Page 5: Geographic performance comparison
│   ├── Profit Analysis.pbix              ← Page 6: Profit drivers & discount impact
│   ├── dashboard_spec.md                 ← Full dashboard specification & DAX measures
│   └── retail_theme.json                 ← Custom dark Power BI theme
│
├── 📂 excel/
│   └── excel_guide.md                    ← Power Query setup + charts + pivot guide
│
└── 📂 output/
    ├── Retail_Sales_Report.xlsx          ← Auto-generated Excel report (5 formatted sheets)
    └── charts/
        ├── 01_monthly_trend.png          ← Monthly Revenue vs Profit line chart
        ├── 02_category_performance.png   ← Category revenue bar + profit pie
        ├── 03_regional_heatmap.png       ← Profit heatmap: Region × Category
        ├── 04_margin_distribution.png    ← Margin % distribution by segment
        ├── 05_discount_vs_profit.png     ← Discount vs Profit scatter (correlation)
        └── 06_top_subcategories.png      ← Top 10 sub-categories by revenue
```

---

## 🗃️ Database Schema

```
customers ──< orders ──< order_items >── products
                │
              regions
```

| Table | Key Columns | Description |
|-------|-------------|-------------|
| `customers` | customer_id, name, segment, region | Customer master data |
| `products` | product_id, name, category, unit_cost, unit_price | Product catalog |
| `orders` | order_id, order_date, ship_mode, customer_id, region_id | Order headers |
| `order_items` | item_id, order_id, product_id, quantity, discount, revenue*, profit* | Line items |
| `regions` | region_id, region_name, manager | Regional hierarchy |

> ✅ `revenue`, `cost`, and `profit` are **generated columns** — calculated automatically by the database engine with no manual errors.

---

## 📊 SQL Features Implemented

### ✅ JOINs
Multi-table joins connecting all 5 tables in every KPI query.
```sql
SELECT c.customer_name, r.region_name, SUM(oi.revenue) AS revenue
FROM customers c
JOIN orders      o  ON c.customer_id = o.customer_id
JOIN regions     r  ON o.region_id   = r.region_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.customer_name, r.region_name;
```

### ✅ CTEs (Common Table Expressions)
Used for multi-step logic like CLV, churn detection, and rolling averages.
```sql
WITH customer_revenue AS (
    SELECT customer_id, SUM(revenue) AS clv
    FROM vw_sales_summary GROUP BY customer_id
)
SELECT *, RANK() OVER (ORDER BY clv DESC) AS clv_rank
FROM customer_revenue;
```

### ✅ Window Functions
`LAG`, `RANK`, `NTILE`, `SUM OVER`, `ROW_NUMBER` for growth rates, rankings, and RFM scoring.
```sql
LAG(revenue) OVER (ORDER BY month)              -- Month-over-month comparison
RANK()       OVER (ORDER BY total_revenue DESC)  -- Product ranking
NTILE(5)     OVER (ORDER BY monetary DESC)       -- RFM score buckets (1–5)
```

### ✅ Views (5 Views)
| View | Purpose |
|------|---------|
| `vw_sales_summary` | Flat transaction table — used across all pages |
| `vw_monthly_kpis` | Monthly aggregated performance metrics |
| `vw_product_performance` | Product rankings with profit margin |
| `vw_customer_clv` | Customer lifetime value and order history |
| `vw_regional_performance` | Region-level scorecards |

### ✅ Stored Procedures (5 Procedures)
| Procedure | Parameters | Use Case |
|-----------|------------|----------|
| `sp_sales_by_date_range` | start_date, end_date | Filter any date range |
| `sp_top_products` | sort_by, limit | Top N by revenue or profit |
| `sp_region_comparison` | region_a, region_b | Compare two regions |
| `sp_customer_health_check` | inactive_days | Identify at-risk customers |
| `sp_profit_analysis` | group_by | Profit by category/region/segment |

```sql
-- Example usage
CALL sp_top_products('profit', 5);
CALL sp_customer_health_check(90);
CALL sp_region_comparison('East', 'West');
```

---

## 📈 KPIs Tracked

| KPI | Definition |
|-----|-----------|
| **Total Sales** | `COUNT(DISTINCT order_id)` |
| **Revenue** | `SUM(qty × unit_price × (1 − discount))` |
| **Profit** | `Revenue − Cost` |
| **Profit Margin %** | `Profit / Revenue × 100` |
| **Average Order Value** | `Revenue / Total Orders` |
| **Top Customers** | Ranked by lifetime revenue |
| **Customer Retention Rate** | Repeat buyers / Total customers × 100 |
| **Monthly Growth Rate** | `(Current − Previous) / Previous × 100` |

---

## 🖥️ Power BI Dashboard — 6 Pages

| # | Page | Key Visuals | Data Source |
|---|------|------------|-------------|
| 1 | 📊 Executive Overview | KPI cards, line chart, donut chart, map | `vw_monthly_kpis`, `vw_sales_summary` |
| 2 | 📈 Sales Analysis | Area chart, bar chart, scatter, KPI tile | `vw_sales_summary` |
| 3 | 👥 Customer Analysis | CLV bar chart, RFM scatter, donut, retention card | `vw_customer_clv` |
| 4 | 📦 Product Performance | Treemap, margin bar chart, scatter, heatmap table | `vw_product_performance` |
| 5 | 🗺️ Regional Analysis | Map, clustered bar, line trend, manager scorecard | `vw_regional_performance` |
| 6 | 💰 Profit Analysis | Waterfall, margin trend, discount scatter, matrix | `vw_sales_summary`, `vw_monthly_kpis` |

### DAX Measures Used
```dax
-- 3-Month Rolling Revenue Average
Rolling 3M Revenue =
CALCULATE(
    SUM(vw_sales_summary[revenue]),
    DATESINPERIOD(vw_sales_summary[order_date], LASTDATE(vw_sales_summary[order_date]), -3, MONTH)
)

-- Year-over-Year Revenue Growth
YoY Revenue Growth % =
VAR CurrentYear = SUM(vw_sales_summary[revenue])
VAR PriorYear   = CALCULATE(SUM(vw_sales_summary[revenue]),
                    SAMEPERIODLASTYEAR(vw_sales_summary[order_date]))
RETURN DIVIDE(CurrentYear - PriorYear, PriorYear) * 100

-- Customer Retention Rate
Customer Retention Rate =
DIVIDE(
    COUNTROWS(FILTER(vw_customer_clv, vw_customer_clv[total_orders] > 1)),
    COUNTROWS(vw_customer_clv)
) * 100
```

---

## 🐍 Python Scripts

### analysis.py — 6 Business Insight Charts
```bash
python python/analysis.py
```
Generates the following dark-themed charts in `output/charts/`:

| Chart | Insight |
|-------|---------|
| `01_monthly_trend.png` | Revenue vs Profit over 12 months |
| `02_category_performance.png` | Revenue bar + Profit pie by category |
| `03_regional_heatmap.png` | Profit heatmap: Region × Category |
| `04_margin_distribution.png` | Margin % distribution by segment |
| `05_discount_vs_profit.png` | Discount vs Profit (correlation line) |
| `06_top_subcategories.png` | Top 10 sub-categories by revenue |

### export_to_excel.py — Formatted Excel Report
```bash
python python/export_to_excel.py
```
Creates `output/Retail_Sales_Report.xlsx` with 5 dark-formatted sheets:
- **KPI Summary** — Executive dashboard card view
- **Sales Data** — Full transaction detail (300 rows)
- **Monthly Trends** — Month-over-month performance
- **Regional Perf** — Region scorecards
- **Product Perf** — Product rankings and margins

---

## 💡 Business Insights (SQL Queries)

| Query | Method | Output |
|-------|--------|--------|
| **Why did profits decrease?** | `LAG()` window function — compares margin MoM | Categories with declining profit flagged |
| **Which products to discontinue?** | Percentile ranking + margin filter | Products with margin < 10% or negative profit |
| **Which region needs investment?** | `LAG()` growth rate per region | High-growth, lower-revenue regions ranked |
| **Customer Lifetime Value** | Full RFM scoring with `NTILE(5)` | Customers tiered: Champion → Lost |

---

## 🚀 Quick Start

### Step 1: Set Up the Database
```sql
-- Run in MySQL Workbench in order:
SOURCE sql/01_schema.sql;
SOURCE sql/02_sample_data.sql;
SOURCE sql/04_views.sql;
SOURCE sql/05_stored_procedures.sql;
```

### Step 2: Run Python Analysis
```bash
pip install -r python/requirements.txt
python python/analysis.py
python python/export_to_excel.py
```

### Step 3: One-Click Automation
```bash
# Just double-click this file:
RUN_ALL.bat
# Regenerates all charts + Excel report automatically
```

### Step 4: Open Power BI Dashboards
1. Open any `.pbix` file from the `powerbi/` folder
2. Apply the dark theme: **View → Themes → Browse** → select `retail_theme.json`
3. Refresh data connection to your MySQL instance

---

## 🎨 Design System

| Token | Hex | Usage |
|-------|-----|-------|
| Background | `#0D1117` | Page background |
| Surface | `#161B22` | Cards and visuals |
| Primary | `#4361EE` | Headers and accents |
| Secondary | `#7209B7` | Chart series 2 |
| Highlight | `#4CC9F0` | KPI values |
| Danger | `#F72585` | Negative metrics |
| Success | `#39D353` | Positive growth |

---

## 🔮 Future Enhancements

- [ ] Predictive sales forecasting (ARIMA / Prophet)
- [ ] Automated email reports (Python + smtplib)
- [ ] Customer churn prediction model (scikit-learn)
- [ ] Real-time streaming dashboard
- [ ] Inventory optimization analysis
- [ ] A/B test analysis for discount strategies

---

## 👩‍💻 Authors

---

### 🧑‍💻 Author 1

**Laxmikanta Roy**

---

### 👩‍💻 Author 2

**Moumita Paul**

---

## ⭐ Acknowledgement

> *Data-driven decisions start with the right questions.*
> *This platform doesn't just show charts — it answers business questions.*

If you found this project useful, please consider giving it a ⭐ on GitHub!

---

*Built with ❤️ using SQL · Python · Power BI · Excel*
