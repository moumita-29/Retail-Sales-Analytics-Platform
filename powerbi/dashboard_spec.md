# Retail Sales Analytics Platform — Power BI Dashboard Specification

## Overview
This document describes the 6 dashboard pages, their visuals, data sources, and DAX measures
to guide the Power BI implementation.

---

## Data Source: SQL Server / MySQL Views
Connect Power BI Desktop to the following views:
| View | Used In |
|------|---------|
| `vw_sales_summary` | All pages |
| `vw_monthly_kpis` | Executive Overview, Sales Analysis |
| `vw_product_performance` | Product Performance |
| `vw_customer_clv` | Customer Analysis |
| `vw_regional_performance` | Regional Analysis |

---

## Page 1: Executive Overview

### Purpose
High-level snapshot of the business — one glance to see health.

### KPI Cards (Top Row)
| Card | Measure |
|------|---------|
| Total Revenue | `SUM(revenue)` |
| Total Profit | `SUM(profit)` |
| Profit Margin % | `DIVIDE(SUM(profit), SUM(revenue)) * 100` |
| Total Orders | `DISTINCTCOUNT(order_id)` |
| Avg Order Value | `DIVIDE(SUM(revenue), DISTINCTCOUNT(order_id))` |

### Visuals
- **Line chart**: Monthly Revenue vs Profit (dual axis)
- **Donut chart**: Revenue by Customer Segment
- **Map**: Revenue by Region (bubble map)
- **KPI tile**: Month-over-month revenue growth %

### Filters
- Date slicer (Year / Month range)
- Region multi-select
- Segment multi-select

---

## Page 2: Sales Analysis

### Purpose
Deep-dive into sales volume, trends, and order patterns.

### Visuals
- **Area chart**: Monthly revenue with 3-month rolling average
- **Bar chart**: Orders by Ship Mode
- **Table**: Top 10 orders by revenue
- **Scatter**: Order Value vs Discount %
- **KPI**: YoY Revenue Change

### DAX Measures
```dax
Rolling 3M Revenue =
CALCULATE(
    SUM(vw_sales_summary[revenue]),
    DATESINPERIOD(vw_sales_summary[order_date], LASTDATE(vw_sales_summary[order_date]), -3, MONTH)
)

YoY Revenue Growth % =
VAR CurrentYear = SUM(vw_sales_summary[revenue])
VAR PriorYear   = CALCULATE(SUM(vw_sales_summary[revenue]),
                    SAMEPERIODLASTYEAR(vw_sales_summary[order_date]))
RETURN DIVIDE(CurrentYear - PriorYear, PriorYear) * 100
```

---

## Page 3: Customer Analysis

### Purpose
Understand who your customers are and their value to the business.

### Visuals
- **Bar chart**: Top 15 customers by Lifetime Revenue
- **Scatter**: CLV vs Order Frequency (bubble = profit)
- **Donut**: Revenue split by segment (Consumer / Corporate / Home Office)
- **Table**: RFM segment breakdown (Champion, Loyal, At Risk, Lost)
- **KPI cards**: Retention Rate %, Avg Customer Lifespan (days)

### DAX Measures
```dax
Customer Retention Rate =
DIVIDE(
    COUNTROWS(FILTER(vw_customer_clv, vw_customer_clv[total_orders] > 1)),
    COUNTROWS(vw_customer_clv)
) * 100

Avg CLV =
AVERAGE(vw_customer_clv[lifetime_revenue])
```

---

## Page 4: Product Performance

### Purpose
Identify star products, underperformers, and discontinue candidates.

### Visuals
- **Treemap**: Revenue by Category → Sub-Category
- **Bar chart** (sorted): Products ranked by Profit Margin %
- **Scatter**: Revenue vs Margin % (color = category, size = units sold)
- **Table**: Products with margin < 10% flagged in red (conditional formatting)
- **Waterfall chart**: Contribution of each category to total profit

### Conditional Formatting Rules
| Field | Condition | Color |
|-------|-----------|-------|
| Profit Margin % | < 10% | 🔴 Red |
| Profit Margin % | 10–25% | 🟡 Yellow |
| Profit Margin % | > 25% | 🟢 Green |

---

## Page 5: Regional Analysis

### Purpose
Compare performance across geographic regions and guide investment decisions.

### Visuals
- **Filled map**: Profit by region
- **Clustered bar**: Revenue & Profit side-by-side per region
- **Line chart**: Monthly revenue trend per region (multi-series)
- **Table**: Region manager scorecard (orders, revenue, margin, growth)
- **KPI**: Best performing region vs worst

### DAX Measures
```dax
Region Growth Rate =
VAR LastMonth    = CALCULATE(SUM(vw_sales_summary[revenue]),
                    PREVIOUSMONTH(vw_sales_summary[order_date]))
VAR CurrentMonth = SUM(vw_sales_summary[revenue])
RETURN DIVIDE(CurrentMonth - LastMonth, LastMonth) * 100
```

---

## Page 6: Profit Analysis

### Purpose
Answer the core business question: **Why did profits change?**

### Visuals
- **Waterfall**: Profit bridge — what drove change month-over-month
- **Bar**: Profit by Category (sorted descending)
- **Line**: Margin % trend over time
- **Scatter**: Discount rate vs Profit per order
- **Matrix**: Profit by Region × Category (heat-coloured cells)
- **KPI**: Months with negative profit growth highlighted

### Business Insight Callouts (Text boxes)
- "📉 Furniture margins dropped 8pp in March — driven by 20% discount promotions"
- "📦 Office Supplies: high volume, low margin — review pricing strategy"
- "🏆 Technology products have the highest ROI at XX% margin"

---

## Power BI Theme
Apply the custom JSON theme file from `/powerbi/retail_theme.json`

| Token | Value |
|-------|-------|
| Background | `#0D1117` |
| Foreground | `#C9D1D9` |
| Accent | `#4361EE` |
| Positive | `#39D353` |
| Negative | `#F72585` |
| Chart 1 | `#4361EE` |
| Chart 2 | `#7209B7` |
| Chart 3 | `#4CC9F0` |
| Chart 4 | `#F72585` |
| Chart 5 | `#3A0CA3` |

---

## Interaction Design
- All visuals cross-filter each other (default Power BI behavior)
- Date slicer synced across all pages
- Region and Segment slicers pinned to navigation pane
- Drill-through: Click any product → Product Detail page
- Tooltip page: Hover any region → mini profit chart

---

## Navigation
Add a page navigation bar on the left side using **Shape buttons**:
```
📊 Executive Overview
📈 Sales Analysis
👥 Customer Analysis
📦 Product Performance
🗺️ Regional Analysis
💰 Profit Analysis
```
