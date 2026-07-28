# -*- coding: utf-8 -*-
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
"""
Retail Sales Analytics Platform
File: python/analysis.py
Description: Python EDA & business insight analysis
             Uses pandas, matplotlib, seaborn, and scipy
"""

import os
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use("Agg")  # non-interactive backend for script mode
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import seaborn as sns
from scipy import stats

# ── Configuration ──────────────────────────────────────────
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "output", "charts")
os.makedirs(OUTPUT_DIR, exist_ok=True)

PALETTE   = ["#4361EE", "#3A0CA3", "#7209B7", "#F72585", "#4CC9F0"]
FONT_SIZE = 12
plt.rcParams.update({
    "figure.facecolor": "#0D1117",
    "axes.facecolor":   "#161B22",
    "axes.edgecolor":   "#30363D",
    "axes.labelcolor":  "#C9D1D9",
    "xtick.color":      "#C9D1D9",
    "ytick.color":      "#C9D1D9",
    "text.color":       "#C9D1D9",
    "grid.color":       "#21262D",
    "grid.linestyle":   "--",
    "font.family":      "DejaVu Sans",
    "font.size":        FONT_SIZE,
})


# ── Data Loading ────────────────────────────────────────────
def load_data(csv_path=None):
    if csv_path and os.path.exists(csv_path):
        df = pd.read_csv(csv_path, parse_dates=["order_date", "ship_date"])
        print(f"[✓] Loaded {len(df):,} rows from {csv_path}")
        return df

    print("[i] Generating synthetic demo data...")
    np.random.seed(42)
    n = 500

    categories  = ["Furniture", "Technology", "Office Supplies"]
    sub_cats    = {
        "Furniture":       ["Chairs", "Tables", "Storage"],
        "Technology":      ["Monitors", "Peripherals", "Accessories"],
        "Office Supplies": ["Paper", "Writing", "Binders"],
    }
    segments    = ["Consumer", "Corporate", "Home Office"]
    regions     = ["North", "South", "East", "West", "Central"]
    ship_modes  = ["Standard Class", "Second Class", "First Class", "Same Day"]

    cat         = np.random.choice(categories, n)
    revenue     = np.random.uniform(100, 2000, n)
    cost_ratio  = np.where(cat == "Furniture", 0.45,
                  np.where(cat == "Technology", 0.55, 0.35))
    cost        = revenue * cost_ratio * np.random.uniform(0.8, 1.2, n)
    profit      = revenue - cost

    base_dates  = pd.date_range("2024-01-01", "2024-12-31", periods=n)
    order_dates = pd.Series(np.random.choice(base_dates, n))

    df = pd.DataFrame({
        "order_id":         range(1, n + 1),
        "order_date":       pd.to_datetime(order_dates.values),
        "customer_segment": np.random.choice(segments, n),
        "region_name":      np.random.choice(regions, n),
        "category":         cat,
        "sub_category":     [np.random.choice(sub_cats[c]) for c in cat],
        "ship_mode":        np.random.choice(ship_modes, n),
        "quantity":         np.random.randint(1, 20, n),
        "discount":         np.random.choice([0, 0.05, 0.10, 0.15, 0.20], n),
        "revenue":          revenue.round(2),
        "cost":             cost.round(2),
        "profit":           profit.round(2),
    })
    df["profit_margin_pct"] = (df["profit"] / df["revenue"] * 100).round(2)
    df["month"]             = df["order_date"].dt.to_period("M").astype(str)
    return df


# ── Helper ──────────────────────────────────────────────────
def save_fig(fig, filename):
    path = os.path.join(OUTPUT_DIR, filename)
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"[✓] Saved → {path}")


# ── Chart 1: Monthly Revenue & Profit Trend ─────────────────
def plot_monthly_trend(df):
    monthly = df.groupby("month")[["revenue", "profit"]].sum().reset_index()
    fig, ax = plt.subplots(figsize=(12, 5))
    ax.plot(monthly["month"], monthly["revenue"], marker="o", color=PALETTE[0],
            linewidth=2.5, label="Revenue")
    ax.plot(monthly["month"], monthly["profit"],  marker="s", color=PALETTE[3],
            linewidth=2.5, label="Profit")
    ax.fill_between(range(len(monthly)), monthly["revenue"].values,
                    monthly["profit"].values, alpha=0.1, color=PALETTE[0])
    ax.set_title("Monthly Revenue vs Profit", fontsize=16, fontweight="bold", pad=15)
    ax.set_xlabel("Month")
    ax.set_ylabel("Amount ($)")
    ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x:,.0f}"))
    ax.set_xticks(range(len(monthly)))
    ax.set_xticklabels(monthly["month"], rotation=45, ha="right")
    ax.legend(framealpha=0.3)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    save_fig(fig, "01_monthly_trend.png")


# ── Chart 2: Revenue by Category ───────────────────────────
def plot_revenue_by_category(df):
    cat_data = (
        df.groupby("category")[["revenue", "profit"]]
        .sum()
        .sort_values("revenue", ascending=False)
        .reset_index()
    )
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    axes[0].barh(cat_data["category"], cat_data["revenue"],
                 color=PALETTE[:len(cat_data)])
    axes[0].set_title("Revenue by Category", fontweight="bold")
    axes[0].xaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x:,.0f}"))
    axes[0].invert_yaxis()

    profit_vals = cat_data["profit"].clip(lower=0)
    axes[1].pie(
        profit_vals,
        labels=cat_data["category"],
        autopct="%1.1f%%",
        colors=PALETTE[:len(cat_data)],
        startangle=140,
        pctdistance=0.8,
    )
    axes[1].set_title("Profit Share by Category", fontweight="bold")
    fig.suptitle("Category Performance", fontsize=16, fontweight="bold")
    fig.tight_layout()
    save_fig(fig, "02_category_performance.png")


# ── Chart 3: Regional Heatmap ───────────────────────────────
def plot_regional_heatmap(df):
    pivot = (
        df.groupby(["region_name", "category"])["profit"]
        .sum()
        .unstack(fill_value=0)
    )
    fig, ax = plt.subplots(figsize=(10, 5))
    sns.heatmap(
        pivot,
        annot=True,
        fmt=".0f",
        cmap="YlOrRd",
        linewidths=0.5,
        ax=ax,
        cbar_kws={"label": "Profit ($)"},
    )
    ax.set_title("Profit Heatmap: Region × Category", fontsize=15, fontweight="bold")
    fig.tight_layout()
    save_fig(fig, "03_regional_heatmap.png")


# ── Chart 4: Profit Margin Distribution ─────────────────────
def plot_margin_distribution(df):
    fig, ax = plt.subplots(figsize=(10, 5))
    for i, seg in enumerate(df["customer_segment"].unique()):
        subset = df[df["customer_segment"] == seg]["profit_margin_pct"].dropna()
        ax.hist(subset, bins=20, alpha=0.6, label=seg,
                color=PALETTE[i % len(PALETTE)], edgecolor="none")
    ax.set_title("Profit Margin Distribution by Customer Segment",
                 fontsize=15, fontweight="bold")
    ax.set_xlabel("Profit Margin (%)")
    ax.set_ylabel("Frequency")
    ax.legend(framealpha=0.3)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    save_fig(fig, "04_margin_distribution.png")


# ── Chart 5: Discount vs Profit Scatter ─────────────────────
def plot_discount_vs_profit(df):
    fig, ax = plt.subplots(figsize=(10, 6))
    unique_cats = df["category"].unique()
    colors = {c: PALETTE[i % len(PALETTE)] for i, c in enumerate(unique_cats)}
    for cat, grp in df.groupby("category"):
        ax.scatter(grp["discount"] * 100, grp["profit"],
                   color=colors[cat], alpha=0.5, s=30, label=cat)
    x_vals = df["discount"].values * 100
    y_vals = df["profit"].values
    slope, intercept, r, p, _ = stats.linregress(x_vals, y_vals)
    x_line = np.linspace(x_vals.min(), x_vals.max(), 100)
    ax.plot(x_line, slope * x_line + intercept, color="#FFFFFF",
            linewidth=1.5, linestyle="--", label=f"Trend (r={r:.2f})")
    ax.set_title("Discount vs Profit — Are Discounts Hurting Margins?",
                 fontsize=14, fontweight="bold")
    ax.set_xlabel("Discount (%)")
    ax.set_ylabel("Profit ($)")
    ax.legend(framealpha=0.3)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    save_fig(fig, "05_discount_vs_profit.png")


# ── Chart 6: Top 10 Sub-categories by Revenue ───────────────
def plot_top_subcategories(df):
    sub_data = (
        df.groupby("sub_category")["revenue"]
        .sum()
        .sort_values(ascending=False)
        .head(10)
        .reset_index()
    )
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = sns.color_palette("coolwarm", len(sub_data))
    bars = ax.barh(sub_data["sub_category"][::-1], sub_data["revenue"][::-1], color=colors)
    ax.bar_label(bars, labels=[f"${v:,.0f}" for v in sub_data["revenue"][::-1]],
                 padding=5, color="#C9D1D9")
    ax.set_title("Top 10 Sub-Categories by Revenue", fontsize=15, fontweight="bold")
    ax.set_xlabel("Revenue ($)")
    ax.xaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x:,.0f}"))
    ax.grid(True, alpha=0.3, axis="x")
    fig.tight_layout()
    save_fig(fig, "06_top_subcategories.png")


# ── Executive Summary ────────────────────────────────────────
def print_executive_summary(df):
    total_revenue   = df["revenue"].sum()
    total_profit    = df["profit"].sum()
    avg_margin      = df["profit_margin_pct"].mean()
    total_orders    = df["order_id"].nunique()
    aov             = total_revenue / total_orders
    top_region      = df.groupby("region_name")["revenue"].sum().idxmax()
    top_cat         = df.groupby("category")["profit"].sum().idxmax()

    print("\n" + "=" * 55)
    print("  RETAIL SALES ANALYTICS -- EXECUTIVE SUMMARY")
    print("=" * 55)
    print(f"  Total Revenue        : ${total_revenue:>12,.2f}")
    print(f"  Total Profit         : ${total_profit:>12,.2f}")
    print(f"  Average Margin       : {avg_margin:>11.1f}%")
    print(f"  Total Orders         : {total_orders:>12,}")
    print(f"  Avg. Order Value     : ${aov:>12,.2f}")
    print(f"  Top Region           : {top_region:>20}")
    print(f"  Most Profitable Cat. : {top_cat:>20}")
    print("=" * 55 + "\n")


# -- Main -----------------------------------------------------
if __name__ == "__main__":
    import sys
    sys.stdout.reconfigure(encoding='utf-8')
    df = load_data()

    print_executive_summary(df)
    print("[→] Generating charts...")
    plot_monthly_trend(df)
    plot_revenue_by_category(df)
    plot_regional_heatmap(df)
    plot_margin_distribution(df)
    plot_discount_vs_profit(df)
    plot_top_subcategories(df)

    print(f"\n[✓] All 6 charts saved to: {OUTPUT_DIR}")
