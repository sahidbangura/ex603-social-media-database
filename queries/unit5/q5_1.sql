-- EX603 Unit 5 | Task 5.1.1
-- Who reacted to each post, and when did the reaction occur?
SELECT l.like_id AS event_id, u.user_id AS actor_id,
       u.user_name AS actor_name, p.post_id AS producer_id,
       p.post_title AS producer_title, l.liked_at AS event_datetime
FROM likes AS l
INNER JOIN users AS u ON l.user_id = u.user_id
INNER JOIN posts AS p ON l.post_id = p.post_id
ORDER BY l.liked_at, l.like_id;

-- EX603 Unit 5 | Task 5.1.2
-- Which producers use the social-media theme tag 'tech'?
-- The junction table connects each post to zero or more hashtags.
SELECT p.post_id AS producer_id, p.post_title,
       h.hashtag_id, h.hashtag_name, ph.tagged_on
FROM posts AS p
INNER JOIN post_hashtags AS ph ON ph.post_id = p.post_id
INNER JOIN hashtags AS h ON h.hashtag_id = ph.hashtag_id
WHERE h.hashtag_name = 'tech'
ORDER BY p.post_id;

-- EX603 Unit 5 | Task 5.1.2 follow-up
-- Which catalog tags are associated with flagged posts 2 and 3?
SELECT p.post_id AS producer_id, p.post_title,
       h.hashtag_id, h.hashtag_name, ph.tagged_on
FROM posts AS p
INNER JOIN post_hashtags AS ph ON p.post_id = ph.post_id
INNER JOIN hashtags AS h ON ph.hashtag_id = h.hashtag_id
WHERE p.post_id IN (2, 3)
ORDER BY h.hashtag_name, p.post_id;

-- EX603 Unit 5 | Task 5.1.3
-- How do posts 2 and 3 compare with other posts from their author country?
WITH reaction_counts AS (
    SELECT post_id, COUNT(*) AS total_reactions,
           COUNT(*) FILTER (
               WHERE reaction_status = 'removed'
                 AND removal_reason = 'Spam detected'
           ) AS spam_removals
    FROM likes
    GROUP BY post_id
)
SELECT p1.post_id AS target_post, p1.author_country,
       COALESCE(r1.total_reactions, 0) AS target_reactions,
       COALESCE(r1.spam_removals, 0) AS target_spam_removals,
       p2.post_id AS comparison_post,
       COALESCE(r2.total_reactions, 0) AS comparison_reactions,
       COALESCE(r2.spam_removals, 0) AS comparison_spam_removals
FROM posts AS p1
INNER JOIN posts AS p2
    ON p1.author_country = p2.author_country
   AND p1.post_id <> p2.post_id
LEFT JOIN reaction_counts AS r1 ON p1.post_id = r1.post_id
LEFT JOIN reaction_counts AS r2 ON p2.post_id = r2.post_id
WHERE p1.post_id IN (2, 3)
ORDER BY p1.post_id, p2.post_id;
