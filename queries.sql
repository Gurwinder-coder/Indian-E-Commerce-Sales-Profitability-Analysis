   -- REVENUE & PROFIT ANALYSIS


-- Q1: What is the total revenue and total profit generated overall?
SELECT
    SUM("Amount") AS total_revenue,
    SUM("Profit")  AS total_profit
FROM main;


-- Q2: What is the monthly revenue and profit trend across the entire dataset?
SELECT
    EXTRACT(MONTH FROM "Order Date"),
    SUM("Amount") AS total_revenue,
    SUM("Profit")  AS total_profit
FROM main
GROUP BY EXTRACT(MONTH FROM "Order Date")
ORDER BY EXTRACT(MONTH FROM "Order Date");


-- Q3: Which category generates the highest revenue?
WITH cte AS (
    SELECT
        "Category",
        SUM("Profit") AS total_profit,
        SUM("Amount") AS total_revenue
    FROM main
    GROUP BY "Category"
)
SELECT "Category", total_revenue
FROM cte
ORDER BY total_revenue DESC
LIMIT 1;

-- Q3: Which category generates the highest profit?
WITH cte AS (
    SELECT
        "Category",
        SUM("Profit") AS total_profit,
        SUM("Amount") AS total_revenue
    FROM main
    GROUP BY "Category"
)
SELECT "Category", total_profit
FROM cte
GROUP BY "Category"
ORDER BY total_profit DESC
LIMIT 1;


-- Q4: Which sub-category has the highest profit margin (profit/amount)?
WITH cte AS (
    SELECT
        "Sub-Category",
        SUM("Profit")/ SUM("Amount") AS profit_margin
    FROM main
    GROUP BY "Sub-Category"
)
SELECT "Sub-Category", ROUND(profit_margin::numeric, 2)
FROM cte
ORDER BY profit_margin DESC
LIMIT 1;

-- Q4: Which sub-category has the lowest profit margin (profit/amount)?
WITH cte AS (
    SELECT
        "Sub-Category",
        SUM("Profit")/ SUM("Amount") AS profit_margin
    FROM main
    GROUP BY "Sub-Category"
)
SELECT "Sub-Category", ROUND(profit_margin::numeric, 2)
FROM cte
ORDER BY profit_margin ASC
LIMIT 1;


-- Q5: Are there any orders with negative profit? Which category/sub-category do they mostly belong to?
SELECT "Sub-Category", SUM("Profit")
FROM main
GROUP BY "Sub-Category"
ORDER BY SUM("Profit") ASC
LIMIT 2;

   -- TARGET VS ACTUAL PERFORMANCE


-- Q6: For each category, compare actual monthly sales against the target
--     (which months did each category hit or miss its target?)
WITH monthly_sales AS (
    SELECT
        "Category",
        DATE_TRUNC('month', "Order Date") AS month,
        SUM("Amount") AS revenue
    FROM main
    GROUP BY
        "Category",
        DATE_TRUNC('month', "Order Date")
)
SELECT
    TO_CHAR(m.month, 'MM-YYYY') AS month,
    m."Category",
    m.revenue,
    t."Target",
    CASE
        WHEN m.revenue >= t."Target" THEN 'Hit'
        ELSE 'Miss'
    END AS target_status
FROM monthly_sales m
JOIN sales_target t
    ON m.month = t."Month"
   AND m."Category" = t."Category"
ORDER BY
    m.month,
    m."Category";


-- Q7: What is the overall target achievement percentage (actual/target) by category?
WITH monthly_sales AS (
    SELECT
        "Category",
        DATE_TRUNC('month', "Order Date") AS month,
        SUM("Amount") AS revenue
    FROM main
    GROUP BY
        "Category",
        DATE_TRUNC('month', "Order Date")
)
SELECT
    TO_CHAR(m.month, 'MM-YYYY') AS month,
    m."Category",
    m.revenue,
    t."Target",
    ROUND((m.revenue::numeric * 100.0) / t."Target"::numeric, 2) AS achievement_percentage
FROM monthly_sales m
JOIN sales_target t
    ON m.month = t."Month"
   AND m."Category" = t."Category"
ORDER BY
    m.month,
    m."Category";



  -- CUSTOMER ANALYSIS

-- Q9: Who are the top 10 customers by total revenue?
SELECT "CustomerName", SUM("Amount")
FROM main
GROUP BY "CustomerName"
ORDER BY SUM("Amount") DESC
LIMIT 10;

-- Q10: Who are the top 10 customers by total profit?
SELECT "CustomerName", SUM("Profit")
FROM main
GROUP BY "CustomerName"
ORDER BY SUM("Profit") DESC
LIMIT 10;


-- Q11: How many unique customers placed orders, and what is the average revenue per customer?
SELECT DISTINCT COUNT("Order ID"), AVG("Amount") AS avg_revenue
FROM main;


-- Q12: Which customers ordered only once vs. more than once (basic repeat-customer view)?
SELECT
    COUNT(CASE WHEN order_count < 2 THEN 1 END) AS order_one_time,
    COUNT(CASE WHEN order_count > 1 THEN 1 END) AS order_more_than_one
FROM (
    SELECT "CustomerName", COUNT("Order ID") AS order_count
    FROM main
    GROUP BY "CustomerName"
) t;



   -- GEOGRAPHY ANALYSIS

-- Q13: Which state generates the highest revenue?
SELECT "State", SUM("Amount")
FROM main
GROUP BY "State"
ORDER BY SUM("Amount") DESC;

-- Q13: Which state generates the highest profit?
SELECT "State", SUM("Profit")
FROM main
GROUP BY "State"
ORDER BY SUM("Profit") DESC;


-- Q14: Which city generates the highest revenue?
SELECT "City", SUM("Amount")
FROM main
GROUP BY "City"
ORDER BY SUM("Amount") DESC;

-- Q14: Which city generates the highest profit?
SELECT "City", SUM("Profit")
FROM main
GROUP BY "City"
ORDER BY SUM("Profit") DESC;


-- Q15: Are there states with high revenue but low/negative profit (potential problem regions)?
SELECT "State", revenue, profit
FROM (
    SELECT
        "State",
        SUM("Amount") AS revenue,
        SUM("Profit") AS profit
    FROM main
    GROUP BY "State"
) t
WHERE revenue > 0
  AND profit < 200;


  -- PRODUCT / ORDER BEHAVIOR

-- Q16: What is the average order value (amount per order)?
SELECT AVG("Amount")
FROM main;


-- Q17: What is the relationship between quantity ordered and profit —
--      do higher-quantity orders tend to be more or less profitable?
SELECT "Quantity", SUM("Profit")
FROM main
GROUP BY "Quantity"
ORDER BY "Quantity" DESC;


-- Q18: Which sub-category has the highest total quantity sold?
SELECT "Sub-Category", COUNT("Order ID")
FROM main
GROUP BY "Sub-Category"
ORDER BY COUNT("Order ID") DESC
LIMIT 1;



  -- TIME-BASED ANALYSIS

-- Q19: What is the month-over-month revenue growth rate?
WITH months AS (
    SELECT
        EXTRACT(MONTH FROM "Order Date") AS month,
        SUM("Amount") AS revenue
    FROM main
    GROUP BY EXTRACT(MONTH FROM "Order Date")
)
SELECT
    month,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))::numeric /
        LAG(revenue) OVER (ORDER BY month)::numeric * 100, 2
    ) AS mom_growth
FROM months
ORDER BY month;


-- Q20: Which month had the highest total revenue across the dataset?
WITH months AS (
    SELECT
        EXTRACT(MONTH FROM "Order Date") AS month,
        SUM("Amount") AS revenue
    FROM main
    GROUP BY EXTRACT(MONTH FROM "Order Date")
)
SELECT month, revenue
FROM months
ORDER BY revenue DESC
LIMIT 1;