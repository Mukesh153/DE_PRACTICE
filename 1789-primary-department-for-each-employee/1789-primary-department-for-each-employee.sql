/* Write your T-SQL query statement below */
SELECT E1.employee_id,E1.department_id 
FROM Employee  E1
JOIN
(
SELECT employee_id,COUNT(employee_id) AS [EMP_COUNT]
 FROM Employee
 GROUP BY employee_id
 HAVING COUNT(employee_id) = 1
) E2 ON E1.employee_id=E2.employee_id 
UNION
SELECT employee_id , department_id  FROM Employee 
WHERE primary_flag='Y';