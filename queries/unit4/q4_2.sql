-- EX603 Unit 4: Task 4.2, Social Media
-- Failure: reaction_status = 'removed' AND removal_reason = 'Spam detected'.

-- 4.2A What are total reactions and spam removals for each post in one pass?
SELECT post_id, COUNT(*) AS total_events,
       SUM(CASE WHEN reaction_status = 'removed' AND removal_reason = 'Spam detected'
                THEN 1 ELSE 0 END) AS failed_events,
       ROUND(100.0 * SUM(CASE WHEN reaction_status = 'removed' AND removal_reason = 'Spam detected'
                              THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS failure_rate_pct
FROM likes
GROUP BY post_id
ORDER BY failed_events DESC, failure_rate_pct DESC, post_id;

-- 4.2B What are regional subtotals and the all-platform grand total?
-- No post-level detail rows; GROUPING = 1 distinguishes the grand total.
SELECT CASE WHEN GROUPING(client_country) = 1 THEN 'ALL REGIONS'
            ELSE client_country END AS region,
       GROUPING(client_country) AS is_grand_total,
       COUNT(*) AS total_events,
       SUM(CASE WHEN reaction_status = 'removed' AND removal_reason = 'Spam detected'
                THEN 1 ELSE 0 END) AS failed_events,
       ROUND(100.0 * SUM(CASE WHEN reaction_status = 'removed' AND removal_reason = 'Spam detected'
                              THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS failure_rate_pct
FROM likes
GROUP BY ROLLUP(client_country)
ORDER BY GROUPING(client_country), client_country;

-- 4.2C What is the reaction-weighted spam-removal baseline for posts with >=10 reactions?
WITH per_post AS (
    SELECT post_id, COUNT(*) AS events,
           COUNT(*) FILTER (WHERE reaction_status = 'removed'
                              AND removal_reason = 'Spam detected') AS spam_removals
    FROM likes
    GROUP BY post_id
), high_volume AS (
    SELECT * FROM per_post WHERE events >= 10
)
SELECT COUNT(*) AS qualifying_posts,
       SUM(events) AS qualifying_events,
       SUM(spam_removals) AS qualifying_failures,
       ROUND(100.0 * SUM(spam_removals) / NULLIF(SUM(events), 0), 2) AS weighted_baseline_pct,
       ROUND(AVG(100.0 * spam_removals / NULLIF(events, 0)), 2) AS mean_post_rate_pct
FROM high_volume;
