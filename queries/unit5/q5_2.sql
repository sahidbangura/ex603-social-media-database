-- EX603 Unit 5 | Task 5.2A.1
-- Which posts have reactions, including posts with none? LEFT JOIN.
SELECT p.post_id AS producer_id, p.post_title,
       COUNT(l.like_id) AS total_reactions
FROM posts AS p LEFT JOIN likes AS l ON p.post_id = l.post_id
GROUP BY p.post_id, p.post_title
ORDER BY p.post_id;

-- EX603 Unit 5 | Task 5.2A.2
-- Which posts appear when only matching event records are kept? INNER JOIN.
SELECT p.post_id AS producer_id, p.post_title,
       COUNT(l.like_id) AS total_reactions
FROM posts AS p INNER JOIN likes AS l ON p.post_id = l.post_id
GROUP BY p.post_id, p.post_title
ORDER BY p.post_id;

-- EX603 Unit 5 | Task 5.2A.3
-- How many distinct producers are lost from INNER JOIN?
WITH all_producers AS (
    SELECT COUNT(DISTINCT p.post_id) AS n
    FROM posts AS p LEFT JOIN likes AS l ON p.post_id = l.post_id
), matched_producers AS (
    SELECT COUNT(DISTINCT p.post_id) AS n
    FROM posts AS p INNER JOIN likes AS l ON p.post_id = l.post_id
)
SELECT a.n AS left_join_producers, m.n AS inner_join_producers,
       a.n - m.n AS excluded_producers
FROM all_producers AS a CROSS JOIN matched_producers AS m;

-- EX603 Unit 5 | Task 5.2A.4
-- Exactly which producers have zero recorded events?
SELECT p.post_id AS producer_id, p.post_title,
       COUNT(l.like_id) AS total_reactions
FROM posts AS p LEFT JOIN likes AS l ON p.post_id = l.post_id
GROUP BY p.post_id, p.post_title
HAVING COUNT(l.like_id) = 0
ORDER BY p.post_id;

-- EX603 Unit 5 | Task 5.2B.1
-- Does reversing table order with RIGHT JOIN preserve the same posts?
SELECT p.post_id AS producer_id, p.post_title,
       COUNT(l.like_id) AS total_reactions
FROM likes AS l RIGHT JOIN posts AS p ON l.post_id = p.post_id
GROUP BY p.post_id, p.post_title
ORDER BY p.post_id;

-- EX603 Unit 5 | Task 5.2B.2
-- Are LEFT JOIN and RIGHT JOIN producer summaries exactly equivalent?
WITH left_result AS (
    SELECT p.post_id, p.post_title, COUNT(l.like_id) AS total_reactions
    FROM posts p LEFT JOIN likes l ON p.post_id = l.post_id
    GROUP BY p.post_id, p.post_title
), right_result AS (
    SELECT p.post_id, p.post_title, COUNT(l.like_id) AS total_reactions
    FROM likes l RIGHT JOIN posts p ON l.post_id = p.post_id
    GROUP BY p.post_id, p.post_title
)
SELECT
  (SELECT COUNT(*) FROM (SELECT * FROM left_result EXCEPT SELECT * FROM right_result) d)
    AS left_only_rows,
  (SELECT COUNT(*) FROM (SELECT * FROM right_result EXCEPT SELECT * FROM left_result) d)
    AS right_only_rows;

-- EX603 Unit 5 | Task 5.2B.3
-- Which producers or event records are unmatched on either side?
SELECT COALESCE(p.post_id, l.post_id) AS producer_id,
       p.post_title, COUNT(l.like_id) AS total_reactions,
       CASE WHEN p.post_id IS NULL THEN 'Missing producer'
            WHEN COUNT(l.like_id) = 0 THEN 'No reactions'
            ELSE 'Has reactions' END AS match_status
FROM posts p FULL OUTER JOIN likes l ON p.post_id = l.post_id
GROUP BY p.post_id, l.post_id, p.post_title
ORDER BY producer_id;

-- EX603 Unit 5 | Task 5.2B.4
-- How many event rows lack a matching producer record?
SELECT COUNT(*) AS orphaned_reaction_events
FROM likes AS l LEFT JOIN posts AS p ON l.post_id = p.post_id
WHERE p.post_id IS NULL;

-- EX603 Unit 5 | Task 5.2C.1
-- Which producers have no events? NOT EXISTS approach.
SELECT p.post_id
FROM posts AS p
WHERE NOT EXISTS (SELECT 1 FROM likes AS l WHERE l.post_id = p.post_id)
ORDER BY p.post_id;

-- EX603 Unit 5 | Task 5.2C.2
-- Which producers have no events? EXCEPT approach.
SELECT post_id FROM posts
EXCEPT
SELECT post_id FROM likes
ORDER BY post_id;

-- EX603 Unit 5 | Task 5.2C.3
-- Do NOT EXISTS and EXCEPT return the same set of producer IDs?
WITH not_exists_result AS (
    SELECT p.post_id FROM posts p
    WHERE NOT EXISTS (SELECT 1 FROM likes l WHERE l.post_id = p.post_id)
), except_result AS (
    SELECT post_id FROM posts EXCEPT SELECT post_id FROM likes
)
SELECT COALESCE(n.post_id, e.post_id) AS producer_id,
       (n.post_id IS NOT NULL) AS found_by_not_exists,
       (e.post_id IS NOT NULL) AS found_by_except
FROM not_exists_result n
FULL OUTER JOIN except_result e ON n.post_id = e.post_id
ORDER BY producer_id;
