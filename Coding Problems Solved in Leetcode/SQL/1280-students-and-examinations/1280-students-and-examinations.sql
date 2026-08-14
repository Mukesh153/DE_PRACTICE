
SELECT S.student_id,S.student_name,SU.subject_name,
CASE WHEN SU.subject_name=E.subject_name THEN COUNT(E.subject_name) ELSE 0 END AS attended_exams
FROM STUDENTS S 
CROSS JOIN SUBJECTS SU
LEFT JOIN Examinations E ON S.student_id=E.student_id AND E.subject_name=SU.subject_name
GROUP BY S.student_id,S.student_name,E.subject_name,SU.subject_name
ORDER BY S.student_id,S.student_name,SU.subject_name;