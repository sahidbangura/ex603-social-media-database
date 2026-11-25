-- Unit 6 / Task 6.3A: Which three events have the highest dwell time for each producer?
-- Ties at third place are resolved deterministically by event ID (ROW_NUMBER);
-- therefore each producer has at most three rows. RANK would include extra tied events.
WITH ranked AS (
    SELECT l.post_id, l.like_id, l.liked_at, l.dwell_ms,
           ROW_NUMBER() OVER (
               PARTITION BY l.post_id ORDER BY l.dwell_ms DESC, l.like_id
           ) AS position_in_post,
           FIRST_VALUE(l.dwell_ms) OVER (
               PARTITION BY l.post_id ORDER BY l.dwell_ms DESC, l.like_id
           ) AS producer_max_dwell_ms
    FROM likes AS l
)
SELECT post_id, like_id, liked_at, dwell_ms, position_in_post, producer_max_dwell_ms
FROM ranked
WHERE position_in_post <= 3
ORDER BY post_id, position_in_post;

-- Unit 6 / Task 6.3B: Is monthly spam-removal performance improving or worsening?
-- Include every calendar month between first and last reaction, even empty months.
WITH bounds AS (
    SELECT DATE_TRUNC('month', MIN(liked_at))::date AS first_month,
           DATE_TRUNC('month', MAX(liked_at))::date AS last_month
    FROM likes
), months AS (
    SELECT GENERATE_SERIES(first_month, last_month, INTERVAL '1 month')::date AS month_start
    FROM bounds
), counts AS (
    SELECT DATE_TRUNC('month', liked_at)::date AS month_start,
           COUNT(*) AS reaction_events,
           COUNT(*) FILTER (
               WHERE reaction_status = 'removed' AND removal_reason = 'Spam detected'
           ) AS spam_removals
    FROM likes
    GROUP BY 1
), series AS (
    SELECT m.month_start, COALESCE(c.reaction_events, 0) AS reaction_events,
           COALESCE(c.spam_removals, 0) AS spam_removals,
           (c.month_start IS NULL) AS missing_month
    FROM months m LEFT JOIN counts c ON c.month_start = m.month_start
), rates AS (
    SELECT *,
           ROUND(100.0 * spam_removals / NULLIF(reaction_events, 0), 2) AS spam_failure_pct
    FROM series
), adjacent AS (
    SELECT *,
           LAG(reaction_events) OVER (ORDER BY month_start) AS prior_month_events,
           LAG(spam_removals) OVER (ORDER BY month_start) AS prior_month_spam_removals,
           LAG(spam_failure_pct) OVER (ORDER BY month_start) AS prior_month_failure_pct
    FROM rates
)
SELECT month_start, reaction_events, spam_removals, missing_month,
       spam_failure_pct, prior_month_events, prior_month_spam_removals,
       prior_month_failure_pct,
       ROUND(100.0 * (reaction_events - prior_month_events)
             / NULLIF(prior_month_events, 0), 2) AS event_volume_change_pct,
       ROUND(100.0 * (spam_failure_pct - prior_month_failure_pct)
             / NULLIF(prior_month_failure_pct, 0), 2) AS failure_rate_relative_change_pct,
       spam_failure_pct - prior_month_failure_pct AS failure_rate_change_percentage_points
FROM adjacent
ORDER BY month_start;

-- Unit 6 / Task 6.3B missing-month audit: Which calendar months have no reaction events?
WITH bounds AS (
    SELECT DATE_TRUNC('month', MIN(liked_at))::date AS first_month,
           DATE_TRUNC('month', MAX(liked_at))::date AS last_month
    FROM likes
), months AS (
    SELECT GENERATE_SERIES(first_month, last_month, INTERVAL '1 month')::date AS month_start
    FROM bounds
)
SELECT m.month_start
FROM months m LEFT JOIN likes l
    ON DATE_TRUNC('month', l.liked_at)::date = m.month_start
GROUP BY m.month_start
HAVING COUNT(l.like_id) = 0
ORDER BY m.month_start;
