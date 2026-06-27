/* Write your T-SQL query statement below */

SELECT A.product_id,A.first_year,B.quantity,B.price FROM
(SELECT product_id,Min(year) as [first_year] from sales
group by product_id) A JOIN
(SELECT 
product_id, YEAR,quantity,price
FROM SALES
group by product_id,quantity,price,YEAR
) B ON A.product_id=B.product_id AND A.first_year=B.YEAR;