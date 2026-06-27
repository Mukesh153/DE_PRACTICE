/* Write your T-SQL query statement below */
SELECT USER_ID,COUNT(follower_id) as [followers_count]
FROM Followers
group by USER_ID;