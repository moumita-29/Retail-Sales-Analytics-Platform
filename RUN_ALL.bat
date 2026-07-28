@echo off
title Retail Sales Analytics Platform - Auto Runner
color 0A

echo.
echo  ============================================
echo   RETAIL SALES ANALYTICS PLATFORM
echo   Auto Runner Script
echo  ============================================
echo.

:: ── Step 1: Python Charts ──────────────────────────────────
echo [1/2] Running Python Analysis (generating 6 charts)...
python -X utf8 python\analysis.py
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] analysis.py failed. Make sure Python is installed.
    pause
    exit /b 1
)

echo.
:: ── Step 2: Excel Export ───────────────────────────────────
echo [2/2] Generating Excel Report...
python -X utf8 python\export_to_excel.py
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] export_to_excel.py failed.
    pause
    exit /b 1
)

echo.
echo  ============================================
echo   ALL DONE!
echo  ============================================
echo.
echo   Charts saved to : output\charts\
echo   Excel saved to  : output\Retail_Sales_Report.xlsx
echo.
echo   Opening output folder...
start "" "output"

pause
