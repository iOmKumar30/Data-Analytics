-- find top 10 highest revenue generating products 
SELECT product_id, SUM(sale_price) AS sales
FROM orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- find top 5 highest selling product in each region
WITH cte AS (
    SELECT 
        region, 
        product_id, 
        SUM(sale_price) AS sales
    FROM orders
    GROUP BY region, product_id
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5;


-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS y, 
        EXTRACT(MONTH FROM order_date) AS m,
        SUM(sale_price) AS sales
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    m, 
    SUM(CASE WHEN y = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN y = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY m
ORDER BY m;

-- For each category, which month had the highest sales:
WITH cte AS (
    SELECT category,
           TO_CHAR(order_date, 'MM/YYYY') AS order_year_month, 
           SUM(sale_price) AS sales
    FROM orders
    GROUP BY category, TO_CHAR(order_date, 'MM/YYYY')
)
SELECT category, order_year_month, sales
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;

-- Which sub-category had the highest growth by profit in 2023 compared to 2022:
WITH cte AS (
    SELECT sub_category,
           EXTRACT(YEAR FROM order_date) AS order_year,
           SUM(profit) AS sales
    FROM orders
    GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
)
, cte2 AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT *
       , (sales_2023 - sales_2022) AS sales_growth
FROM cte2
ORDER BY sales_growth DESC
LIMIT 1;


