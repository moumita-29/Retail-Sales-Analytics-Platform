# Excel Reporting Guide

## Overview
The `python/export_to_excel.py` script automatically generates a formatted Excel report
from your database views. You can also manually build this in Excel using Power Query.

---

## Workbook Sheets

| Sheet | Data Source | Purpose |
|-------|-------------|---------|
| 📊 KPI Summary | Calculated | Executive dashboard card view |
| Sales Data | `vw_sales_summary` | Full transaction detail |
| Monthly Trends | `vw_monthly_kpis` | Month-over-month performance |
| Product Perf. | `vw_product_performance` | Product ranking & margins |
| Regional Perf. | `vw_regional_performance` | Region scorecards |

---

## Power Query Connection (Manual Setup)

1. Open Excel → **Data** → **Get Data** → **From Database** → **From MySQL Database**
2. Server: `localhost`, Database: `retail_sales_db`
3. Load each view as a separate query:
   - `vw_sales_summary`
   - `vw_monthly_kpis`
   - `vw_product_performance`
   - `vw_customer_clv`
   - `vw_regional_performance`

---

## Recommended Excel Charts

### Sheet: Monthly Trends
- **Insert** → **Line Chart** → Revenue & Profit on dual axis
- Add a calculated column for `Growth %` using formula:
  ```excel
  =(C3-C2)/C2
  ```

### Sheet: Product Perf.
- **Conditional Formatting** → Color scale on `profit_margin_pct`:
  - Red: < 10%
  - Yellow: 10–25%
  - Green: > 25%

### Sheet: Regional Perf.
- **Insert** → **Clustered Bar Chart** → `region_name` vs `total_revenue`, `total_profit`

---

## Pivot Table: Quick KPI Summary

1. Click anywhere in the **Sales Data** sheet
2. **Insert** → **PivotTable**
3. Drag fields:
   - **Rows**: `category` or `region_name`
   - **Values**: `revenue` (Sum), `profit` (Sum), `profit_margin_pct` (Average)
4. Format values as Currency / Percentage

---

## Conditional Formatting Rules for KPI Summary

| Metric | Rule | Format |
|--------|------|--------|
| Profit Margin | < 0% | Red fill |
| Profit Margin | 0–15% | Yellow fill |
| Profit Margin | > 15% | Green fill |
| Growth % | Negative | Red arrow icon |
| Growth % | Positive | Green arrow icon |

---

## Automated Report Refresh

Run the Python script to regenerate the Excel file with fresh data:
```bash
cd python
pip install -r requirements.txt
python export_to_excel.py
```

The script will:
1. Connect to MySQL (or use demo data)
2. Pull all view data
3. Generate a fully-formatted Excel workbook
4. Save to `output/Retail_Sales_Report.xlsx`
