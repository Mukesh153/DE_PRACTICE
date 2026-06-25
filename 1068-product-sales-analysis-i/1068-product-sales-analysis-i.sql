/* Write your T-SQL query statement below */
SELECT 
B.product_name, A.YEAR, A.PRICE
FROM SALES A JOIN PRODUCT B
ON A.product_id=B.product_id;