-- Unit 6 / Task 6.1.1: How unusual is each reaction's dwell time compared with its own post?
SELECT l.like_id, l.post_id, l.liked_at, l.dwell_ms,
       ROUND(AVG(l.dwell_ms) OVER (PARTITION BY l.post_id), 2) AS producer_avg_dwell_ms,
       ROUND(l.dwell_ms - AVG(l.dwell_ms) OVER (PARTITION BY l.post_id), 2) AS difference_from_avg_ms
FROM likes AS l
ORDER BY l.post_id, l.liked_at, l.like_id;

-- Unit 6 / Task 6.1.1 comparison: What is the average dwell time for each post if rows are collapsed?
SELECT post_id, COUNT(*) AS reaction_events, ROUND(AVG(dwell_ms), 2) AS avg_dwell_ms
FROM likes
GROUP BY post_id
ORDER BY post_id;

-- Unit 6 / Task 6.1.1 row-count check: How many event rows versus group rows?
SELECT (SELECT COUNT(*) FROM likes) AS event_rows,
       (SELECT COUNT(*) FROM (SELECT post_id FROM likes GROUP BY post_id) g) AS grouped_rows;

-- Unit 6 / Task 6.1.2: How do ROW_NUMBER, RANK and DENSE_RANK handle tied producer activity?
WITH counts AS (
    SELECT p.post_id, p.post_title, COUNT(l.like_id) AS reaction_events
    FROM posts AS p LEFT JOIN likes AS l ON l.post_id = p.post_id
    GROUP BY p.post_id, p.post_title
)
SELECT post_id, post_title, reaction_events,
       ROW_NUMBER() OVER (ORDER BY reaction_events DESC, post_id) AS row_number,
       RANK() OVER (ORDER BY reaction_events DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY reaction_events DESC) AS dense_rank_no_gaps
FROM counts
ORDER BY reaction_events DESC, post_id;

-- Unit 6 / Task 6.1.3: Which quartile of reaction volume does each post occupy?
-- ROW_NUMBER-style deterministic sorting for NTILE means ties can span a boundary.
WITH counts AS (
    SELECT p.post_id, p.post_title, COUNT(l.like_id) AS reaction_events
    FROM posts p LEFT JOIN likes l ON l.post_id = p.post_id
    GROUP BY p.post_id, p.post_title
)
SELECT post_id, post_title, reaction_events,
       NTILE(4) OVER (ORDER BY reaction_events DESC, post_id) AS volume_quartile
FROM counts
ORDER BY volume_quartile, reaction_events DESC, post_id;

-- Unit 6 / Task 6.1.3 tie audit: Which equal event counts were split between quartiles?
WITH counts AS (
    SELECT p.post_id, COUNT(l.like_id) AS reaction_events
    FROM posts p LEFT JOIN likes l ON l.post_id=p.post_id
    GROUP BY p.post_id
), bands AS (
    SELECT *, NTILE(4) OVER (ORDER BY reaction_events DESC, post_id) AS volume_quartile
    FROM counts
)
SELECT reaction_events, MIN(volume_quartile) AS first_quartile,
       MAX(volume_quartile) AS last_quartile, COUNT(*) AS tied_producers
FROM bands
GROUP BY reaction_events
HAVING COUNT(*) > 1 AND MIN(volume_quartile) <> MAX(volume_quartile)
ORDER BY reaction_events DESC;
