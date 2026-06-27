/* Write your T-SQL query statement below */
SELECT CLASS
FROM Courses
GROUP BY CLASS
HAVING COUNT(CLASS) >=5;