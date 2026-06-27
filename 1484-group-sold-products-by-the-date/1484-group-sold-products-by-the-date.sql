/* Write your T-SQL query statement below */

WITH UniqueActivities AS (
    -- Step 1: Get unique combinations of date and product
    SELECT DISTINCT sell_date, product
    FROM Activities
)
-- Step 2: Aggregate the deduplicated rows
SELECT 
    sell_date,
    COUNT(*) AS num_sold,
    STRING_AGG(product, ',') WITHIN GROUP (ORDER BY product ASC) AS products
FROM UniqueActivities
GROUP BY sell_date;