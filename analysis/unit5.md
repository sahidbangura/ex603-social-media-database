# Unit 5 — Connecting the Tables (Social Media)

**Database:** Instructor-provided `ex603_data`, a 2023 reference dataset.
**Entity mapping:** reaction event = `likes`; producer = `posts`; actor = `users`; catalog = `hashtags`, reached through `post_hashtags`.

## Task 5.1 — Connect producers to their data

**Three-table join.** Joining `likes`, `users`, and `posts` returned 200 reaction events with the reacting user's ID and name, post ID and title, and event time. A trust-and-safety review screen could display who reacted to a reported post, when each event occurred, and which producer was involved. This complements the aggregate spam-removal rates from Unit 4.

**Junction-table analysis.** Posts 2 and 3 both have the `tech` hashtag. Post 2 also has `fitness` and `travel`; Post 3 also has `food`. The `post_hashtags` relation records many-to-many associations without duplicating hashtag definitions in the posts table. Without it, reliably finding all shared tags would require repeating values, parsing multivalued fields, or redesigning the schema. Shared tags show a characteristic, not a cause of moderation removals.

**Self join.** Comparing posts in the same `author_country` returned five comparisons. Post 2 (Vietnam, 16 reactions, 3 spam removals) can be compared with posts 6 (21 reactions) and 11 (16 reactions). Post 3 (Brazil, 13 reactions, 2 spam removals) can be compared with posts 5 (18 reactions), 12 (17), and 13 (11). Author country alone does not explain differences in activity or moderation. `author_country` is a post attribute and must not be confused with `likes.client_country`, which describes the reaction's origin.

## Task 5.2 — Records that joins exclude

**LEFT versus INNER.** A LEFT JOIN retained all **15** posts, whereas an INNER JOIN retained only **13 distinct** posts. The missing producers were **Post_14 (ID 14)** and **Post_15 (ID 15)**, both with **zero reaction rows**. Counts used distinct producer IDs rather than event-row counts.

**RIGHT versus LEFT.** Reversing the table order and using RIGHT JOIN returned 15 producers, as the LEFT JOIN did. The included comparison SQL tests full row-set equivalence in both directions; the observed screenshot confirms the same producer count, while the row-set difference test should still be run and captured.

**FULL OUTER.** The full outer query returned 15 grouped producer records. It can expose unmatched posts **and** unmatched reactions whose post identifier is absent from `posts`. The visible screenshot does not independently prove whether orphaned reaction rows exist; the extra orphan check in `q5_2.sql` verifies that separately. A LEFT JOIN starting from posts would not reveal orphaned reactions.

**NOT EXISTS versus EXCEPT.** Both methods returned exactly **14 and 15**, agreeing on the no-reaction posts. `NOT EXISTS` is a correlated absence check; `EXCEPT` subtracts the set of post IDs appearing in reactions from all post IDs. Both work here; `NOT EXISTS` can make a matching condition clearer, while `EXCEPT` is concise for sets of identifiers.

**Interpretation and decision.** Zero recorded reactions do **not** establish that a post was never published, viewed, or actively promoted. Leadership should check visibility, publication date, discoverability, traffic exposure, and ingestion completeness. An INNER JOIN-only report hides posts with no reaction events, creating a misleading impression that every producer was active. A creator operations team could audit posts 14 and 15 and investigate onboarding or exposure barriers before taking action.

## Task 5.3 — Join performance

**CROSS JOIN.** The `hashtags` table has **5** rows and `post_media` has **28** rows: **5 × 28 = 140** combinations. PostgreSQL returned 140, matching the expected Cartesian product. It could be useful for constructing a candidate matrix of hashtag/media combinations, but many combinations may have no business meaning. An accidental CROSS JOIN can multiply dataset sizes sharply.

**Execution plan.** The EXPLAIN plan for the 200-event three-table report has 13 lines. PostgreSQL estimated 200 output rows. It starts with sequential scans of `likes` (estimated 200 rows) and `users` (estimated 100), then uses a **Hash Join** on `l.user_id = u.user_id`. A **Nested Loop** accesses `posts` through **Memoize** (cache key `l.post_id`) and an **Index Scan using posts_pkey** (condition `post_id = l.post_id`). A final **Sort** orders by `l.liked_at, l.like_id`. PostgreSQL likely considers a small table scan and hash build economical, while indexed post lookup is efficient for the small number of distinct post IDs and can benefit from repeated cache hits. The joins themselves do not guarantee the required order, so sorting is a separate operation.

**Growth risks and design choices.** With substantially more reactions, sequential reading and sorting a much larger event stream may become expensive; depending on selectivity and memory, hashing and nested-loop lookups may also change in cost. PostgreSQL uses table and index statistics to estimate row counts and select a plan. Understanding its choices helps detect scale-related bottlenecks rather than relying on assumptions. This is an estimated `EXPLAIN` plan, not an `EXPLAIN ANALYZE` measurement; pgAdmin's wall-clock UI time is not a measured plan-node execution time.

## Reflection (150–250 words)

The plan for my three-table join showed me that PostgreSQL does not have to use the same algorithm for every relationship. It used a Hash Join to match reactions with users, but a Nested Loop with indexed and memoized lookups to find posts. That makes sense for this dataset: there are 200 reactions, and many reactions reference the same small set of posts. A sequential scan of the relatively small event and user tables is inexpensive, while caching repeated post lookups avoids unnecessary work.

If the event table grew to millions of reactions, the optimizer might make different choices. The cost of scanning all events and sorting them by time could become substantial. An index supporting a selective date range or relevant join key might make an index-based plan attractive, especially if a report only needs a small subset of rows. If most rows still match, a hash-based strategy could remain preferable to large numbers of individual index lookups. Changes in the number of distinct posts, index availability, table statistics, and available work memory could also alter the decision.

I would compare EXPLAIN ANALYZE plans after those changes and check actual versus estimated row counts before concluding that a different join algorithm is faster.
