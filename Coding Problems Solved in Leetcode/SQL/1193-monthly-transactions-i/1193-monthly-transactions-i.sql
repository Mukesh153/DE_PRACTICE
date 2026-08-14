/* Write your T-SQL query statement below */


SELECT YearMonth as [Month],country,
Count(YearMonth) as trans_count,
Sum(case when state='approved' then 1 else 0 end) as approved_count,
Sum(amount) as trans_total_amount,
Sum(case when state='approved' then amount else 0 end) as 
approved_total_amount
 FROM
(
SELECT 
FORMAT(CAST(trans_date AS DATE), 'yyyy-MM') AS YearMonth,
*
FROM TRANSACTIONS
)T
group by T.YearMonth,T.country
order by T.YearMonth;
