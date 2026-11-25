-- Unit 6 / Task 6.2A: How did reaction dwell time change between adjacent events on post 2?
WITH sequenced AS (
    SELECT l.post_id, l.like_id, l.liked_at, l.dwell_ms,
           LAG(l.dwell_ms) OVER (
               PARTITION BY l.post_id ORDER BY l.liked_at, l.like_id
           ) AS previous_dwell_ms,
           LEAD(l.dwell_ms) OVER (
               PARTITION BY l.post_id ORDER BY l.liked_at, l.like_id
           ) AS next_dwell_ms
    FROM likes AS l
)
SELECT post_id, like_id, liked_at, dwell_ms, previous_dwell_ms, next_dwell_ms,
       dwell_ms - previous_dwell_ms AS delta_from_previous_ms
FROM sequenced
WHERE post_id = 2
ORDER BY liked_at, like_id;

-- Unit 6 / Task 6.2B: How does platform activity accumulate toward a target of 200 reactions?
-- A seven-row moving average represents seven *observed calendar days*,
-- NOT necessarily seven consecutive dates when days with zero events are missing.
WITH daily AS (
    SELECT liked_at::date AS event_day,
           COUNT(*) AS reactions,
           COUNT(*) FILTER (
               WHERE reaction_status = 'removed' AND removal_reason = 'Spam detected'
           ) AS spam_removals
    FROM likes
    GROUP BY liked_at::date
), timeline AS (
    SELECT event_day, reactions, spam_removals,
           SUM(reactions) OVER (
               ORDER BY event_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS running_reactions,
           ROUND(AVG(reactions) OVER (
               ORDER BY event_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ), 2) AS moving_avg_7_observed_days
    FROM daily
)
SELECT event_day, reactions, spam_removals, running_reactions,
       200 AS historical_event_target,
       ROUND(100.0 * running_reactions / 200, 2) AS target_completion_pct,
       moving_avg_7_observed_days
FROM timeline
ORDER BY event_day;

-- Unit 6 / Task 6.2B peer-tie note: ROWS and RANGE work differently with duplicate order keys.
-- In ROWS a frame advances physical rows; RANGE groups ORDER BY peers together.
-- The daily grouping above ensures one row per date before using a ROWS frame.

-- Unit 6 / Task 6.2C: Which posts have gaps of at least 30 days between adjacent reactions?
WITH ordered_events AS (
    SELECT l.post_id, l.like_id, l.liked_at,
           LAG(l.liked_at) OVER (
               PARTITION BY l.post_id ORDER BY l.liked_at, l.like_id
           ) AS previous_liked_at
    FROM likes AS l
), gaps AS (
    SELECT post_id, like_id, previous_liked_at, liked_at,
           liked_at - previous_liked_at AS inactive_interval
    FROM ordered_events
    WHERE previous_liked_at IS NOT NULL
)
SELECT post_id, like_id, previous_liked_at, liked_at, inactive_interval
FROM gaps
WHERE inactive_interval >= INTERVAL '30 days'
ORDER BY inactive_interval DESC, post_id, liked_at;
