# Unit 4 — From Rows to Insight (Social Media)

## Scope and definitions

The instructor's `social.sql` reference dataset has 200 reactions in 2023, associated with 13 posts that received reactions and 30 reacting users. `likes` is the event table, `posts` the producer, `users` the actor, and `dwell_ms` the theme metric. `client_country` is where a reaction originated, not the post author's location. Results describe the **entire supplied dataset**, not the current quarter.

A failure is specifically `reaction_status = 'removed' AND removal_reason = 'Spam detected'`. The denominator is all reactions, including active and flagged events. Other removals are not necessarily spam. The business owner should validate the failure definition before using the measure for payouts.

## Task 4.1 — Measure the platform

1. **Platform statistics.** 200 reactions, 30 distinct reacting users, total dwell 3,628,190 ms, average dwell 18,140.95 ms, minimum 0 ms, maximum 70,860 ms. The 0 ms minimum warrants investigation because removed reactions may deliberately have zero recorded dwell; it is not automatically invalid data.
2. **By producer.** Posts 6 (21 reactions), 8 (20), and 10 (19) lead in activity. Aggregate dwell averages conceal skewed distributions, zeros and differences in sample size. The two posts without reactions do not appear in the grouped `likes` results.
3. **HAVING threshold.** A minimum of 10 reactions keeps 12 posts and 194 of 200 reactions (97%). It excludes the six-reaction post 4. This is a practical screening cutoff, **not** a claim of statistical certainty; we would need more observations and uncertainty estimates.
4. **Two dimensions.** Grouping by post and client country gives 62 combinations and allows regional comparisons. For example, post 2 in Brazil has two spam removals out of four reactions (50%), but that tiny denominator makes a confident conclusion inappropriate.

**Who acts?** A Trust and Safety or creator-monetization lead, with the analytics owner, should investigate producer-level exceptions. Event counts conceal who generated the reactions and why some were removed; averages hide zeros and the distribution of engagement. Next, examine individual events by post ID, time, status, removal reason, and client country; check duplicate activity and moderation consistency.

## Task 4.2 — Additional leadership breakdowns

**Part A, conditional aggregation.** Two side-by-side questions: (1) How many total reactions does each post have? (2) How many of those were removed specifically for spam? One grouping query preserves all reactions in the denominator and assigns zero failures when none occur. Overall, 12 of 200 reactions are spam removals (**6.00%**) while 34 of 200 were removed for any reason (**17.00%**).

**Part B, ROLLUP.** Regional operations directors need region subtotals instead of post-level details. Country rows have `is_grand_total = 0`; the ALL REGIONS row has `is_grand_total = 1`. The 200-event grand total provides the platform-wide rate needed for a decision that no individual regional row can establish.

| Client country | Events | Spam removals | Failure rate |
|---|---:|---:|---:|
| Brazil | 39 | 3 | 7.69% |
| India | 40 | 4 | 10.00% |
| UK | 40 | 1 | 2.50% |
| US | 38 | 3 | 7.89% |
| Vietnam | 43 | 1 | 2.33% |
| **All regions** | **200** | **12** | **6.00%** |

**Part C, two-step CTE.** The question: What is the combined spam-removal baseline for posts with at least 10 reactions? The first CTE creates per-post counts, the next stage retains high-volume posts, and the final aggregation calculates a reaction-weighted rate: **11 / 194 = 5.67%**. A plain average of post percentages answers a different question by weighting small and large posts equally.

## Reflection (150–250 words)

Conditional aggregation is useful because it keeps multiple related measurements in one grouped result. In this assignment, I need the number of reactions for each post and the number removed for spam. If I ran separate filtered queries, one might count all reactions while another counts only spam removals. I would then need to join their results carefully by post ID. A post with no spam removals might disappear from the filtered query entirely, so an incorrect join could hide it or create a missing value. Conditional aggregation preserves the denominator and returns zero failures for that post.

At one million rows, this difference becomes more important. Separate queries may require scanning and grouping a large event table twice, depending on indexes and the database's execution plan. One aggregation can often compute both counts while scanning the relevant rows once, reducing I/O and reconciliation work. It also helps ensure the totals use identical grouping and date criteria. This does not mean one query is always faster: PostgreSQL may optimize independent filters with suitable indexes. I would verify performance using EXPLAIN ANALYZE. The bigger benefit is having a consistent, auditable definition of the failure rate.

## Evidence and limitations

Seven original pgAdmin screenshots were provided. Most display the end rather than the complete text of lengthy statements, so they need to be retaken for the strict full-query-and-output rubric. The submitted screenshots should be captured from pgAdmin with the full executed query and its result legible in one image, without cropping or compositing.
