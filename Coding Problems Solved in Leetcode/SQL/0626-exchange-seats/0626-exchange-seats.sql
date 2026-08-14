SELECT 
    CASE 
        -- If it's an odd ID and it's the last row, keep the ID the same
        WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM Seat) THEN id
        -- If it's an odd ID, look at the next ID
        WHEN id % 2 = 1 THEN id + 1
        -- If it's an even ID, look at the previous ID
        ELSE id - 1
    END AS id,
    student
FROM Seat
ORDER BY id;
