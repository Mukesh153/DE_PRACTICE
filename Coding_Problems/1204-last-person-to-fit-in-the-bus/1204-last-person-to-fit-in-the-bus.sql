WITH CTE AS 
(
SELECT  NAME,MAX([Cumulated Weight Sum]) as [MAX_WEIGHT] FROM 
(
SELECT 
Turn,person_id AS ID,person_name AS NAME, WEIGHT,
SUM(WEIGHT) OVER (ORDER BY Turn) AS [Cumulated Weight Sum]
FROM QUEUE 
) T
WHERE [Cumulated Weight Sum] < = 1000
GROUP BY NAME
)
SELECT TOP 1 NAME AS person_name FROM  CTE ORDER BY MAX_WEIGHT DESC;