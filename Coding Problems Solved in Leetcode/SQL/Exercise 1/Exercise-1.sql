/*
1) Find the top 3 customers in the last month based on sales
2) Find the top 3 Materials by each category in the last month
3) Find the set of customers who have not placed order in the last month
4) Find the customers who purchased every day in the last month
5) Find the customers who did not purchase MTRLID=1 in the last month or there total purchase in MTRLID=1 was less than $100
6) Find the running sum of sales of each customer arranged by date
7) Find those set of customers who has purchased above $1000 for more than 5 months in the previous year
8) Find the set of customers who has not purchased anything in the last 3 months
9) Write a query to remove the duplicates from the Order without any additional table creation
10) Find the number of customers who has purchased in the last 3 months after a gap of 6months.
*/  ---> GitHub

SELECT * FROM ORDERTABLE;  -- Needs renaming 
SELECT * FROM PRODUCT;
----------------------------------------------------------------------------------------------------
-- 1st Problem --> Find the top 3 customers in the last month based on sales
SELECT top 3 CUST_ID FROM ORDERTABLE
WHERE ORDERDATE BETWEEN DATEADD(day, 1, EOMONTH(GETDATE(), -2)) and EOMONTH(GETDATE(), -1)
order by sales desc;
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 2nd Problem --> Find the top 3 Materials by each category in the last month

SELECT TOP 3 T.CATEGORY FROM
(
SELECT  P.CATEGORY,SUM(OT.SALES) AS [TOTAL_SALES]
FROM ORDERTABLE OT JOIN PRODUCT P ON OT.MTRLID=P.MTRLID
WHERE ORDERDATE BETWEEN DATEADD(day, 1, EOMONTH(GETDATE(), -2)) and EOMONTH(GETDATE(), -1)
GROUP BY P.CATEGORY
)T 
ORDER BY [TOTAL_SALES] DESC ;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 3rd Problem --> Find the set of customers who have not placed order in the last month

SELECT DISTINCT CUST_ID FROM  ORDERTABLE 
WHERE ORDERDATE NOT BETWEEN DATEADD(day, 1, EOMONTH(GETDATE(), -2)) and EOMONTH(GETDATE(), -1)
ORDER BY CUST_ID;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 4th Problem --> Find the customers who purchased every day in the last month
SELECT CUST_ID, COUNT(DISTINCT ORDERDATE) as DaysOrdered
FROM ORDERTABLE
WHERE ORDERDATE BETWEEN DATEADD(day, 1, EOMONTH(GETDATE(), -2)) AND EOMONTH(GETDATE(), -1)
GROUP BY CUST_ID
HAVING COUNT(DISTINCT ORDERDATE) = (
    -- Total unique ordering dates available last month
    SELECT COUNT(DISTINCT ORDERDATE) 
    FROM ORDERTABLE 
    WHERE ORDERDATE BETWEEN DATEADD(day, 1, EOMONTH(GETDATE(), -2)) AND EOMONTH(GETDATE(), -1)
);

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 5th Problem --> Find the customers who did not purchase MTRLID=1 in the last month or there total purchase in MTRLID=1 was less than $100

SELECT DISTINCT CUST_ID 
FROM ORDERTABLE
WHERE ORDERDATE BETWEEN DATEADD(day, 1, EOMONTH(GETDATE(), -2)) AND EOMONTH(GETDATE(), -1) AND MTRLID != 1
UNION 
SELECT CUST_ID 
FROM ORDERTABLE
WHERE MTRLID=1 
group by CUST_ID
HAVING SUM(SALES) < 100;
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 6th Problem --> Find the running sum of sales of each customer arranged by date

SELECT distinct CUST_ID,ORDERDATE,
Sum(sales) over (partition by CUST_ID order by ORDERDATE asc) as [Running Sum of sales]
from ORDERTABLE;

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 7th Problem --> Find those set of customers who has purchased above $1000 for more than 5 months in the previous year

SELECT CUST_ID FROM
(
SELECT  CUST_ID,MONTH(ORDERDATE) AS [MONTH_NUM],SUM(SALES) AS [TOTAL_SALES]
FROM ORDERTABLE
WHERE ORDERDATE BETWEEN DATEFROMPARTS(YEAR(GETDATE())-1, 1, 1) and DATEFROMPARTS(YEAR(GETDATE())-1, 12, 31)
GROUP by CUST_ID,MONTH(ORDERDATE)
HAVING SUM(SALES) > 1000
)T
GROUP BY CUST_ID
HAVING COUNT([MONTH_NUM]) > 5;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 8th Problem --> Find the set of customers who has not purchased anything in the last 3 months

SELECT  CUST_ID FROM ORDERTABLE

EXCEPT

SELECT  CUST_ID
FROM ORDERTABLE
WHERE ORDERDATE  BETWEEN  DATEADD(DD,1,EOMONTH(GETDATE(),-4)) AND EOMONTH(GETDATE(),-1) ;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 9th Problem --> Write a query to remove the duplicates from the Order without any additional table creation

;WITH CTE AS
(
SELECT * ,
ROW_NUMBER() OVER (PARTITION BY CUST_ID,MTRLID,ORDERDATE,SALES ORDER BY  CUST_ID,MTRLID,ORDERDATE,SALES) AS [RNK]
FROM ORDERTABLE
)
DELETE FROM CTE WHERE [RNK] > 1;

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 10th Problem --> Find the number of customers who has purchased in the last 3 months after a gap of 6months.

SELECT  CUST_ID
FROM ORDERTABLE
WHERE ORDERDATE  BETWEEN  DATEADD(DD,1,EOMONTH(GETDATE(),-4)) AND EOMONTH(GETDATE(),-1) 

EXCEPT

SELECT  CUST_ID
FROM ORDERTABLE
WHERE ORDERDATE  BETWEEN  DATEADD(DD,1,EOMONTH(GETDATE(),-10)) AND  EOMONTH(GETDATE(),-4) ;

----------------------------------------------------------------------------------------------------