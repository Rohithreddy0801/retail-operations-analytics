-- Retail Operations Analytics Portfolio Project
-- PostgreSQL-compatible SQL
-- Dataset: synthetic practice data; not employer or customer data.

DROP TABLE IF EXISTS retail_orders;

CREATE TABLE retail_orders (
    order_id         VARCHAR(20) PRIMARY KEY,
    order_date       DATE NOT NULL,
    month            VARCHAR(3) NOT NULL,
    region           VARCHAR(30) NOT NULL,
    category         VARCHAR(40) NOT NULL,
    sales_channel    VARCHAR(20) NOT NULL,
    units            INTEGER NOT NULL CHECK (units > 0),
    unit_price       NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    revenue          NUMERIC(12,2) NOT NULL CHECK (revenue >= 0),
    cost             NUMERIC(12,2) NOT NULL CHECK (cost >= 0),
    profit           NUMERIC(12,2) NOT NULL,
    delivery_days    INTEGER NOT NULL CHECK (delivery_days > 0),
    delivery_status  VARCHAR(10) NOT NULL,
    returned         VARCHAR(3) NOT NULL,
    customer_rating  INTEGER NOT NULL CHECK (customer_rating BETWEEN 1 AND 5)
);

-- After creating the table, import retail_orders.csv using your database tool.
-- In PostgreSQL psql, replace the path below with the full path on your computer:
-- \copy retail_orders FROM '/full/path/retail_orders.csv' CSV HEADER;

-- 1. Data-quality audit
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids,
    SUM(CASE WHEN revenue <> units * unit_price THEN 1 ELSE 0 END) AS revenue_mismatches,
    SUM(CASE WHEN profit <> revenue - cost THEN 1 ELSE 0 END) AS profit_mismatches
FROM retail_orders;

-- 2. Executive KPIs
SELECT
    COUNT(*) AS total_orders,
    SUM(units) AS units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(revenue), 2) AS average_order_value,
    ROUND(100.0 * SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 1) AS on_time_delivery_pct,
    ROUND(100.0 * SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct,
    ROUND(AVG(customer_rating), 2) AS average_rating
FROM retail_orders;

-- 3. Monthly performance trend
SELECT
    DATE_TRUNC('month', order_date)::date AS order_month,
    COUNT(*) AS orders,
    SUM(units) AS units_sold,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 1) AS profit_margin_pct
FROM retail_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;

-- 4. Regional performance ranking
SELECT
    region,
    COUNT(*) AS orders,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(AVG(revenue), 2) AS average_order_value,
    DENSE_RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM retail_orders
GROUP BY region
ORDER BY revenue_rank, region;

-- 5. Category performance and return risk
SELECT
    category,
    COUNT(*) AS orders,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 1) AS profit_margin_pct,
    ROUND(100.0 * SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM retail_orders
GROUP BY category
ORDER BY revenue DESC;

-- 6. Sales-channel comparison
SELECT
    sales_channel,
    COUNT(*) AS orders,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(AVG(revenue), 2) AS average_order_value,
    ROUND(AVG(customer_rating), 2) AS average_rating
FROM retail_orders
GROUP BY sales_channel
ORDER BY revenue DESC;

-- 7. Delivery performance by region
SELECT
    region,
    COUNT(*) AS orders,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 1) AS on_time_pct
FROM retail_orders
GROUP BY region
ORDER BY on_time_pct, region;

-- 8. Effect of delivery performance on customer ratings
SELECT
    delivery_status,
    COUNT(*) AS orders,
    ROUND(AVG(customer_rating), 2) AS average_rating,
    ROUND(100.0 * SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM retail_orders
GROUP BY delivery_status
ORDER BY delivery_status;

-- 9. Highest-value orders for operational review
SELECT
    order_id,
    order_date,
    region,
    category,
    sales_channel,
    revenue,
    profit,
    delivery_status,
    returned
FROM retail_orders
ORDER BY revenue DESC
LIMIT 10;

-- 10. Categories performing above their category average
WITH category_average AS (
    SELECT category, AVG(revenue) AS average_revenue
    FROM retail_orders
    GROUP BY category
)
SELECT
    r.order_id,
    r.category,
    r.revenue,
    ROUND(c.average_revenue, 2) AS category_average
FROM retail_orders r
JOIN category_average c ON r.category = c.category
WHERE r.revenue > c.average_revenue
ORDER BY r.category, r.revenue DESC;

-- 11. Month-over-month revenue change
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS order_month,
        SUM(revenue) AS revenue
    FROM retail_orders
    GROUP BY DATE_TRUNC('month', order_date)
), movement AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND((revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0) * 100, 1) AS month_on_month_change_pct
FROM movement
ORDER BY order_month;

-- 12. Reusable summary view for Power BI
CREATE OR REPLACE VIEW monthly_operations_summary AS
SELECT
    DATE_TRUNC('month', order_date)::date AS order_month,
    region,
    category,
    sales_channel,
    COUNT(*) AS orders,
    SUM(units) AS units_sold,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 1) AS on_time_pct,
    ROUND(100.0 * SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct,
    ROUND(AVG(customer_rating), 2) AS average_rating
FROM retail_orders
GROUP BY DATE_TRUNC('month', order_date), region, category, sales_channel;

SELECT *
FROM monthly_operations_summary
ORDER BY order_month, region, category, sales_channel;

