/* Write your T-SQL query statement below */

SELECT 
teacher_id , count(distinct subject_id) as cnt
FROM Teacher
group by teacher_id;