-- EX603 Unit 5 | Task 5.3A.1
-- How many rows are in each small source table?
SELECT (SELECT COUNT(*) FROM hashtags) AS hashtag_count,
       (SELECT COUNT(*) FROM post_media) AS media_count;

-- EX603 Unit 5 | Task 5.3A.2
-- What combinations are produced by CROSS JOIN? (Sample rows.)
SELECT h.hashtag_id, h.hashtag_name, pm.post_id, pm.media_code
FROM hashtags h CROSS JOIN post_media pm
ORDER BY h.hashtag_id, pm.post_id
LIMIT 20;

-- EX603 Unit 5 | Task 5.3A.3
-- Does the Cartesian-product count equal the product of source counts?
WITH counts AS (
    SELECT (SELECT COUNT(*) FROM hashtags) AS hashtag_count,
           (SELECT COUNT(*) FROM post_media) AS media_count
), cross_result AS (
    SELECT COUNT(*) AS cross_join_count
    FROM hashtags h CROSS JOIN post_media pm
)
SELECT c.hashtag_count, c.media_count,
       c.hashtag_count * c.media_count AS expected_rows,
       cr.cross_join_count AS actual_rows,
       CASE WHEN c.hashtag_count * c.media_count = cr.cross_join_count
            THEN 'MATCH' ELSE 'MISMATCH' END AS verification
FROM counts c CROSS JOIN cross_result cr;

-- EX603 Unit 5 | Task 5.3B
-- What plan and join algorithms does PostgreSQL choose for the 5.1.1 report?
EXPLAIN
SELECT l.like_id AS event_id, u.user_id AS actor_id,
       u.user_name AS actor_name, p.post_id AS producer_id,
       p.post_title AS producer_title, l.liked_at AS event_datetime
FROM likes AS l
INNER JOIN users AS u ON l.user_id = u.user_id
INNER JOIN posts AS p ON l.post_id = p.post_id
ORDER BY l.liked_at, l.like_id;
