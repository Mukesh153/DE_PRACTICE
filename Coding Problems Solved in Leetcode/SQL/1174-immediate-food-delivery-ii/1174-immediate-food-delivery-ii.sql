/* Write your T-SQL query statement below */
with cte as
(
SELECT 
SUM (CASE WHEN [First Order Date] = [First customer_pref_delivery_date] THEN 1 END) AS [Total Immediate],
COUNT(*) AS [TOTAL FIRST ORDERS]
 from
(
SELECT 
customer_id,
Min(order_date) as [First Order Date],
Min(customer_pref_delivery_date) as [First customer_pref_delivery_date] 
FROM Delivery
group by customer_id
) t
)
SELECT 
CAST(([Total Immediate]*1.0*100) / NULLIF([TOTAL FIRST ORDERS],0) AS DECIMAL(10,2)) AS [immediate_percentage]
FROM CTE;