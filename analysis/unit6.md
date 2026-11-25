# Unit 6 — Analytics and the Portfolio

**Theme:** Social media reactions. **Database:** instructor-provided `ex603_data`. **Event:** a `likes` reaction. **Producer:** `posts`. **Metric:** dwell time (`dwell_ms`); failure is a reaction removed for the reason `Spam detected`.

> Evidence status: The SQL files are prepared but the Unit 6 queries have not yet been executed against the user's PostgreSQL instance. Replace the checkpoints below with actual outputs before submission.

## Task 6.1 — Window functions versus aggregation

**Event-level question:** Which reactions have exceptionally long or short dwell times relative to other reactions on the same post? `AVG(dwell_ms) OVER (PARTITION BY post_id)` keeps each event, its original time and its dwell metric next to the post average. `GROUP BY post_id` supplies only the average and reaction count per producer, so individual outliers and timestamps disappear. A row-count query in `q6_1.sql` explicitly checks both output sizes. Historical Unit 4 totals suggested 200 event rows and 13 groups with events, but rerun the new check for the evidence capture.

**Ranking decision:** A creator leaderboard could rank posts by number of reactions. I would use `DENSE_RANK` for a public-facing leaderboard because posts with equal event counts deserve equal ranks, and the following rank should not skip numbers. `ROW_NUMBER` is appropriate for a fixed-number display, where a deterministic secondary order breaks ties; `RANK` gives equal ranks but leaves gaps. The query shows all three side by side. Record a tied activity count visible in the actual output: **[verify tie]**.

**NTILE decision:** `NTILE(4)` creates four nearly equal-sized groups of posts ordered by reaction count. Because it assigns rows, not groups of equal values, posts with a tie may be separated across a boundary. The included tie-audit query checks whether that happens; if not, report that observation rather than saying it did.

## Task 6.2 — Adjacent events, cumulative activity, gaps

**LAG/LEAD and delta:** On post 2, previous and next dwell times reveal event-level swings that a producer-wide average hides. A large delta is a signal to inspect event timing, content/context, measurement quality and whether a reaction was moderated. It is not evidence of a deliberate change by the creator. Record the largest positive and negative observed deltas: **[run q6_2.sql]**.

**Running total:** A plain `SUM` gives one historical total; a running total shows when it accumulated and how close the platform was to a clearly stated benchmark of **200 historical reaction events**. The benchmark is illustrative and retrospective, not a promised future-quarter operating target. The moving average uses seven observed daily rows to dampen event-volume volatility without discarding each day's results. Crucially, these are seven *observed* days, not always seven consecutive calendar days, because missing days are not filled in this query.

**ROWS versus RANGE:** If two records have the same ordering value, `ROWS` counts physical rows and its cumulative total can advance one peer at a time; `RANGE` with the default peer-inclusive frame covers all rows sharing the sort value together. Grouping to one row per calendar date avoids duplicate-date peers in the chosen daily calculation.

**Gaps:** `LAG` finds intervals between consecutive reaction timestamps for each post, and an outer query selects intervals of at least 30 days. The result shows gaps *between observed events*, not proven creator inactivity. A gap might reflect low demand, visibility changes, missing ingestion, or other recording limitations. Check post status, activity logs and event pipeline completeness before deciding which interpretation applies. Record a producer and the dates from an actual matching row: **[run gap query; if none match, state so and adjust threshold with justification]**.

## Task 6.3 — Reporting patterns

**Top three:** An engagement-review panel could surface three highest-dwell reaction events per post. Three is a manageable investigation shortlist with more context than one outlier and less noise than ten. `ROW_NUMBER` breaks a tie at third place using `like_id`, so no producer returns more than three rows. `FIRST_VALUE` repeats that producer's maximum dwell on each selected row. A different policy using `RANK` would retain all ties and could return more than three.

**Month-over-month:** The monthly series reports reaction volume, spam removals, spam-removal percentage, prior-month values and changes. It fills every month from the first observed event to the last, so a missing month is not mistaken for an adjacent month. A missing or zero-denominator month produces NULL rather than a manufactured failure rate. A major change could reflect volume mix, moderation policies or actual reaction quality; leaders should validate event counts, definitions and sample size before intervention.

**Actionable finding needed from execution:** **[Record actual monthly rates and trend from q6_3.sql. Do not claim improving or worsening until checked.]**

## Reflection (150–250 words)

Window functions helped me answer a question that a grouped average could not: which individual reactions behaved differently from the other reactions on the same post? With GROUP BY, I can calculate the average dwell time of each post, but I lose the reaction IDs, their timestamps, and the original dwell-time measurements. I could join the aggregate back to the events, but that adds another step and more room for errors. With AVG OVER PARTITION BY, the event and its producer average appear on the same row, so the difference is easy to inspect.

The same idea applies to monitoring platform activity over time. A total number of reactions says how much engagement the dataset contains, but not when that engagement accumulated or when activity slowed. A running SUM makes the progression visible; LAG adds context from the previous event, and a moving average helps distinguish short-term noise from a more sustained change. Each method requires careful decisions about ordering and grouping. For example, a seven-row moving average is not necessarily seven calendar days if dates are missing. I also learned that a ranking function encodes a policy: tied producers may need equal rank, while a fixed-size review panel may need a deterministic tie-breaker. The SQL should reflect that product decision rather than treating the ranking as neutral.
