/* Write your T-SQL query statement below */
SELECT A.unique_id, B.NAME
FROM EmployeeUNI A RIGHT JOIN  Employees B
ON A.id= B.ID;

