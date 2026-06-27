/* Write your T-SQL query statement below */

--SELECT visited_on,
--Sum(amount) over (order by visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount
--from 
--Customer;

;with RestaurantGrowth AS (
SELECT visited_on,
Sum(amount) over (order by visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount,
Round(cast(AVG (amount * 1.0)  over (order by visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as float),2) as [average_amount],
ROW_NUMBER() OVER (ORDER BY visited_on) AS RowNum
 FROM
(
SELECT visited_on, SUM (amount) as [amount]
FROM Customer 
group by visited_on
) T
)
SELECT visited_on,amount,average_amount from RestaurantGrowth where RowNum > 6;
;
