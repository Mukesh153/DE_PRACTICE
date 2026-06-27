/* Write your T-SQL query statement below */

;WITH dedup_email as
(
    SELECT id, email,
    ROW_NUMBER() OVER (PARTITION BY EMAIL ORDER BY ID ASC)    AS [EMAIL_DUP_RNK]
    FROM Person
)
DELETE FROM dedup_email WHERE EMAIL_DUP_RNK > 1;