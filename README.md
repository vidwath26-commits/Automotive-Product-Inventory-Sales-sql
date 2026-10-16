# Automotive Product, Inventory & Sales Analysis Using MySQL

## Project overview
An end-to-end SQL portfolio project analyzing a **synthetic automotive aftermarket dataset** covering product catalog composition, supplier coverage, inventory, sales performance, and order-line returns. The analysis combines automotive product-data domain knowledge with MySQL querying and business interpretation.

> **Dataset disclosure:** All records are synthetic practice data. Insights are illustrative, not claims about a real business. Monetary amounts are reported in dataset currency units; no currency is assumed.

## Dataset
Seven tables: `Products`, `Categories`, `Suppliers`, `Customers`, `Orders`, `Order_Lines`, and `Inventory`.

| Table | Rows |
|---|---:|
| Products | 12,000 |
| Categories | 8 |
| Suppliers | 120 |
| Customers | 5,000 |
| Orders | 25,000 |
| Order_Lines | 60,000 |
| Inventory | 30,000 |

Inventory may contain multiple rows per product across warehouses. Parent order and order-line statuses can disagree in this synthetic dataset.

## Business questions and SQL methods
| Query | Business question | Core SQL skills |
|---|---|---|
| Q01 | Product count by category | LEFT JOIN, COUNT, GROUP BY |
| Q02 | Product-category-supplier mapping | Multiple LEFT JOINs |
| Q03 | On-hand and reserved inventory by product | SUM, COALESCE, GROUP BY |
| Q04 | Top 20 products by eligible sales | Multi-table JOIN, SUM, LIMIT |
| Q05 | Order-line return rate by category | Conditional COUNT, percentage |
| Q06 | Supplier combined active-product list prices | WHERE, SUM, GROUP BY |
| Q07 | Products above their category's average list price | Correlated subquery, AVG |
| Q08 | Monthly eligible sales and prior-month sales | CTE, DATE_FORMAT, LAG |
| Q09 | Top three sales-ranked products in each category | CTE, DENSE_RANK |
| Q10 | Running monthly eligible sales total | CTE, window SUM |
| Q11 | Category share of eligible sales | Multiple CTEs, CROSS JOIN, NULLIF |
| Q12 | Highest-priced active product per supplier | ROW_NUMBER, PARTITION BY |

## Metric definitions
- **Eligible calculated sales value:** `SUM(OL.Quantity * OL.Unit_Sale_Price * (1 - OL.Discount_Pct))` for orders with `Order_Status IN ('Completed','Shipped')` **and** lines with `Line_Status = 'Fulfilled'`. This is a project-defined analytical measure, **not recognized accounting revenue**.
- **Return rate (Q05):** `Returned` order lines divided by all order lines within each category; no parent order status restriction. This is **line-based**, not unit- or order-based.
- **Combined list-price value (Q06):** sum of listed prices of active products assigned to each supplier, **not** inventory valuation or realized sales.
- **Inventory availability:** on-hand less reserved units; warehouse rows are aggregated to product level in Q03.
- **Ranking ties:** Q09 uses `DENSE_RANK` (may return more than three products when ties occur); Q12 uses `ROW_NUMBER` and Product_ID as a deterministic tie-breaker.

## Selected findings
- **7,350,764.60** eligible calculated sales value across January 2024–September 2026 (Q10 ending cumulative value).
- **Electrical** contributes the largest category share, **13.71%**, while **Cooling** contributes **11.60%** (Q11).
- **Exhaust** has the broadest product catalog, **1,557 of 12,000 products** (Q01), but is not the largest category by eligible sales (Q11).
- **2,990 of 60,000 order lines** are marked returned, an overall order-line return rate of **4.98%**; **Interior** has the highest category rate, **5.36%** (Q05).
- **3,754,902** units on hand and **618,392** reserved across the product catalog; these are summed product-level inventory results (Q03).
- **4,079 products (33.99%)** have list prices above their own category's average (Q07).
- The corrected top 20 eligible-sales products sum to **174,718.70** (Q04).

See [Business findings](docs/business_findings.md) for interpretation and caveats.

## Repository structure
```text
automotive_mysql_portfolio/
├── README.md
├── sql/
│   ├── schema.sql
│   └── portfolio_queries.sql
├── data/
│   ├── *.csv                 # synthetic source dataset
│   └── DATASET_SOURCE_README.txt
├── results/
│   └── Q01.csv ... Q12.csv   # sequentially numbered outputs
└── docs/
    ├── business_findings.md
    └── practice_questions.md
```

## How to reproduce
1. Install MySQL 8+ and open MySQL Workbench.
2. Run `sql/schema.sql` to create the required schema and tables. Check its instructions and select the correct database before running queries.
3. Import the seven source CSVs from `data/` into their corresponding tables. Adjust file paths and local-infile settings for your environment.
4. Execute each statement in `sql/portfolio_queries.sql` and compare the outputs to `results/`.

**Note:** The supplied schema and data are preserved from the original practice pack; import steps may depend on local MySQL permissions and configuration.

## Tools and techniques
MySQL, MySQL Workbench, SQL joins, aggregations, correlated subqueries, common table expressions (CTEs), window functions (`LAG`, `DENSE_RANK`, `ROW_NUMBER`, running `SUM`).

## Limitations
Synthetic data may not follow real operational business rules; order and line statuses can be inconsistent. No returns reason, true profit margin, or accounting revenue recognition data are established here. Monthly rounded amounts may sum to a cent different from an unrounded cumulative calculation.
