# Indian E-Commerce Sales & Profitability Analysis

A retailer hands you a year of order data and one question: where is the money actually being made, and where is it quietly leaking out? This project answers that using an Indian e-commerce dataset spanning April 2018 to March 2019 — 500 orders, 1,500 order lines, three product categories, and a set of monthly sales targets nobody had checked against actuals.

![Dashboard overview](screenshots/dashboard-overview.png)

## The numbers going in

₹4.32L in total revenue. ₹24K in profit. A 5.55% margin — thin, but not the real story. The real story showed up once I split the data apart: **1 in 3 order lines were losing money.** Not close to breakeven. Actually negative.

## What I wanted to know

Three questions drove the whole analysis:

1. Which categories and sub-categories are profitable, and which ones are quietly dragging the business down?
2. Is the company hitting its monthly sales targets, or missing them consistently in specific categories?
3. Who are the customers actually driving revenue, and is the business retaining them?

## What I found

**Furniture looks fine until you check the margin.** It brought in ₹1.27L in revenue — the second-highest of the three categories — but converted almost none of it to profit. 1.8% margin. Tables specifically ran at -17.7%, meaning every table sold lost money on average. Electronics, by contrast, carried 46.6% of total profit despite similar revenue to Clothing.

**Revenue swings hard by month.** January pulled in ₹61,439. July managed ₹12,966. Almost a 5x gap, in the same business, same categories. Anyone building a hiring plan or inventory forecast off a flat monthly average would be badly wrong twice a year.

**Repeat customers are rare.** Just 31% of the 332 customers in this dataset ordered more than once. That's not necessarily bad for a young e-commerce operation, but it does mean the business is spending most of its energy on one-time acquisition rather than retention — worth flagging to anyone thinking about where to invest next.

**Target tracking wasn't happening before this.** The dataset came with monthly sales targets per category that, as far as I could tell, weren't being compared against actuals anywhere. I built that comparison — which months each category hit or missed, and by how much — and it's now part of both the SQL analysis and the notebook.

## How I got there

The raw data came in three separate CSVs — orders, order line items, and sales targets — with the usual mess: 60 fully blank rows in the orders file, inconsistent casing on state and city names, order dates and target months stored as text instead of dates. `data_cleaning.ipynb` handles all of that: dropping null rows, standardizing text fields, parsing dates properly, merging orders with their line items, and loading the result into a local PostgreSQL database.

From there, `eda.ipynb` does the actual digging — category and sub-category profit breakdowns, the target-vs-actual comparison, a look at whether higher-quantity orders are more or less profitable, customer concentration, and the seasonal revenue pattern. `queries.sql` mirrors a lot of this same analysis in raw SQL, since I wanted the same questions answered two ways rather than assuming one tool was right.

The dashboard pulls the findings into something a business stakeholder could actually open and use — category filters, a year toggle, and a "Key Insights" panel calling out the specific problems instead of just leaving someone to spot them in a chart.

## Repository structure

```
├── data/
│   ├── raw/                  # original CSVs (orders, order details, sales target)
│   └── cleaned/               # cleaned output from data_cleaning.ipynb
├── data_cleaning.ipynb        # null handling, text cleanup, merge, load to Postgres
├── eda.ipynb                  # category/sub-category, target vs actual, customer, seasonal analysis
├── queries.sql                # same business questions answered in SQL
├── dashboard.pbix             # Power BI dashboard
└── screenshots/                # dashboard screenshots for this README
```

## Tools

Python (pandas, matplotlib, seaborn) for cleaning and exploration, PostgreSQL for the SQL side of the analysis, Power BI for the dashboard.

## What I'd do differently next time

The profit margin at the sub-category level needs to be a proper weighted average (sum of profit divided by sum of revenue), not an average of individual order margins — I caught this mistake partway through and it's fixed now, but it's a reminder to check the math before trusting a chart. I'd also want a second year of data to say anything confident about the seasonal pattern rather than treating one January-to-July swing as a rule.
