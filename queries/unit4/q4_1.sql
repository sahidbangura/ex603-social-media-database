-- EX603 Unit 4: Task 4.1, Social Media
-- Scope: all supplied 2023 reactions. Spam failure = removed for 'Spam detected'.

-- 4.1.1 What are the full-platform dwell statistics and distinct reacting users?
SELECT COUNT(*) AS event_count,
       SUM(dwell_ms) AS total_dwell_ms,
       ROUND(AVG(dwell_ms), 2) AS avg_dwell_ms,
       MIN(dwell_ms) AS min_dwell_ms,
       MAX(dwell_ms) AS max_dwell_ms,
       COUNT(DISTINCT user_id) AS distinct_actors
FROM likes;

-- 4.1.1 additional quality check: which statuses contain zero dwell time?
SELECT reaction_status, COUNT(*) AS events,
       COUNT(*) FILTER (WHERE dwell_ms = 0) AS zero_dwell_events
FROM likes
GROUP BY reaction_status
ORDER BY reaction_status;

-- 4.1.2 How many reactions and what average dwell time does each post have?
SELECT post_id, COUNT(*) AS event_count,
       ROUND(AVG(dwell_ms), 2) AS avg_dwell_ms
FROM likes
GROUP BY post_id
ORDER BY event_count DESC, post_id;

-- 4.1.3 Which posts have at least 10 reactions, and their spam-removal rates?
SELECT post_id, COUNT(*) AS event_count,
       COUNT(*) FILTER (WHERE reaction_status = 'removed' AND removal_reason = 'Spam detected') AS spam_removals,
       ROUND(100.0 * COUNT(*) FILTER (WHERE reaction_status = 'removed' AND removal_reason = 'Spam detected')
             / NULLIF(COUNT(*), 0), 2) AS spam_failure_pct
FROM likes
GROUP BY post_id
HAVING COUNT(*) >= 10
ORDER BY spam_failure_pct DESC, event_count DESC, post_id;

-- 4.1.4 How does performance vary simultaneously by post and client region?
SELECT post_id, client_country AS region, COUNT(*) AS event_count,
       ROUND(AVG(dwell_ms), 2) AS avg_dwell_ms,
       COUNT(*) FILTER (WHERE reaction_status = 'removed' AND removal_reason = 'Spam detected') AS spam_removals,
       ROUND(100.0 * COUNT(*) FILTER (WHERE reaction_status = 'removed' AND removal_reason = 'Spam detected')
             / NULLIF(COUNT(*), 0), 2) AS spam_failure_pct
FROM likes
GROUP BY post_id, client_country
ORDER BY post_id, client_country;
