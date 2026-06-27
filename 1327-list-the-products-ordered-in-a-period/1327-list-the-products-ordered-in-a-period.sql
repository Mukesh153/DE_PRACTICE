/* Write your T-SQL query statement below */
SELECT 
P.product_name, SUM (O.unit) AS [unit]
FROM Orders O join Products P  
on P.product_id=O.product_id
WHERE YEAR(order_date) = 2020 AND MONTH(order_date) = 2
GROUP BY P.product_id,P.product_name
HAVING SUM (O.unit) >=100;