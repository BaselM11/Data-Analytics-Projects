--find top 10 highest reveue generating products
SELECT TOP 10 product_id, SUM(sale_price) as sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC


--find top 5 highest selling products in each region
WITH CTE AS
(SELECT region,product_id,sum(sale_price) as sales
FROM df_orderS
GROUP BY region,product_id)
SELECT *
FROM
(SELECT *
,ROW_NUMBER() OVER (PARTITION BY REGION ORDER BY sales desc) as rn
FROM CTE) as A
WHERE rn<=5



--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH CTE AS 
(
SELECT YEAR(order_date) as year,MONTH(order_date) as month, sum(sale_price) as sales
FROM df_orders
GROUP BY YEAR(order_date),MONTH(order_date)
)
SELECT month
,SUM(CASE WHEN year=2022 THEN sales ELSE 0 END) as sales_2022
,sum(CASE WHEN year=2023 THEN sales ELSE 0 END) as sales_2023
FROM CTE
GROUP BY MONTH
order by month


----for each category which month had highest sales 
WITH CTE AS (
SELECT category,format(order_date,'yyyyMM') as order_month,sum(sale_price) as sales
FROM df_orders
GROUP BY category,format(order_date,'yyyyMM')
)
SELECT * FROM(
SELECT *
, ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) as rn
FROM CTE) AS A
WHERE rn<2



--which sub category had highest growth by profit in 2023 compare to 2022
WITH CTE AS 
(
SELECT sub_category,YEAR(order_date) as order_year,SUM(sale_price) as sales
FROM df_orders
GROUP BY sub_category,YEAR(order_date)
),CTE2 AS(
SELECT sub_category
,SUM(CASE WHEN order_year = 2022 THEN sales Else 0 END) as year_2022
,SUM(CASE WHEN order_year=2023 then sales else 0 end) as year_2023
FROM CTE
GROUP BY sub_category)
SELECT TOP 1  *,year_2023-year_2022
FROM CTE2
ORDER BY year_2023-year_2022 DESC
