/* Write your T-SQL query statement below */
SELECT Department,Employee,Salary FROM 
(
SELECT 
D.name as Department,
E.name as Employee,
E.Salary,
Dense_Rank() over (Partition by D.name order by Salary desc) as [Salary_Rnk]
FROM Employee E 
join Department D on E.departmentId=D.id
) T WHERE T.Salary_Rnk <= 3;
