# Retail Operations Analytics

An end-to-end data analytics portfolio project exploring retail sales, profitability, delivery performance, returns and customer ratings.

> The dataset is synthetic and was created for learning and portfolio use. It does not contain Amazon, employer or customer data.

## Business question

How can a retail operations team improve commercial performance, delivery reliability and customer outcomes?

## Tools

- Excel: structured data, validation, formulas, KPI analysis and dashboarding
- SQL: data-quality checks, aggregations, CTEs, window functions, ranking and reusable views
- Power BI: planned interactive dashboard and DAX measures

## Files

- `retail_orders.csv` — 240 synthetic order records
- `retail_analysis.sql` — PostgreSQL-compatible setup and analysis queries
- `Retail_Operations_Analytics_Project.xlsx` — Excel analysis workbook (kept with the main project files)

## Questions answered

- What are total revenue, profit, average order value and order volume?
- Which regions and categories generate the strongest results?
- How does revenue change month by month?
- Where are late deliveries and returns concentrated?
- How do delivery outcomes relate to customer ratings?

## SQL techniques demonstrated

- Data-quality checks
- `GROUP BY`, `CASE`, `COUNT`, `SUM` and `AVG`
- CTEs and joins
- `LAG` for month-on-month comparisons
- `DENSE_RANK` for regional ranking
- Safe division using `NULLIF`
- Reusable analytical views for Power BI

## Next stage

Build a Power BI dashboard with KPI cards, monthly revenue trend, regional comparison, category performance and delivery/return analysis.

## Author

Rohith Reddy Vemireddy  
[LinkedIn](https://www.linkedin.com/in/rohith-reddy-7b898040b/) · [GitHub](https://github.com/Rohithreddy0801)
