# Unit 6 — Analytics and the Portfolio

**Theme:** Social media reactions. **Database:** instructor-provided `ex603_data`. **Event:** a `likes` reaction. **Producer:** `posts`. **Metric:** dwell time (`dwell_ms`); failure is a reaction removed for the reason `Spam detected`.

> Evidence status: Core Unit 6 queries were executed in pgAdmin against `ex603_data` and their outputs reviewed. Supplemental tie-audit and missing-month audit queries in the SQL files are still available for independent verification. Submission screenshots with full SQL and output have not yet been committed.

## Task 6.1 — Window functions versus aggregation

**Event-level question:** Which reactions have exceptionally long or short dwell times relative to other reactions on the same post? `AVG(dwell_ms) OVER (PARTITION BY post_id)` keeps each event, its original time and its dwell metric next to the post average. `GROUP BY post_id` supplies only the average and reaction count per producer, so individual outliers and timestamps disappear. A row-count query in `q6_1.sql` explicitly checks both output sizes. The window query returned **200 rows**, while the grouped query returned **13 rows**. Post 1 had 11 reactions and an average dwell time of **16,026.36 ms**, with individual reactions ranging above and below that average.

**Ranking decision:** A creator leaderboard could rank posts by number of reactions. I would use `DENSE_RANK` for a public-facing leaderboard because posts with equal event counts deserve equal ranks, and the following rank should not skip numbers. `ROW_NUMBER` is appropriate for a fixed-number display, where a deterministic secondary order breaks ties; `RANK` gives equal ranks but leaves gaps. The query shows all three side by side. The executed leaderboard displayed a tie: Posts **5 and 7** each had **18 reactions**. ROW_NUMBER assigned positions 4 and 5, RANK gave both rank 4 and skipped to 6, and DENSE_RANK gave both rank 4 and continued to 5.

**NTILE decision:** `NTILE(4)` creates four nearly equal-sized groups of posts ordered by reaction count. Because it assigns rows, not groups of equal values, posts with a tie may be separated across a boundary. The executed 15-post output confirmed a boundary split: Posts **5 and 7**, tied at **18 reactions**, were assigned to **bands 1 and 2** respectively. A tie audit query is also provided in `q6_1.sql`.

## Task 6.2 — Adjacent events, cumulative activity, gaps

**LAG/LEAD and delta:** On post 2, previous and next dwell times reveal event-level swings that a producer-wide average hides. A large delta is a signal to inspect event timing, content/context, measurement quality and whether a reaction was moderated. It is not evidence of a deliberate change by the creator. The post-2 query returned **16 reactions**. Among the visible rows, event 13 increased by **19,890 ms** from the previous event, while event 14 fell by **15,210 ms**. The remaining eight rows were not shown in the provided screenshot, so these are examples, not verified extrema.

**Running total:** A plain `SUM` gives one historical total; a running total shows when it accumulated and how close the platform was to a clearly stated benchmark of **200 historical reaction events**. The benchmark is illustrative and retrospective, not a promised future-quarter operating target. The daily query returned **155 observed dates** and the moving average uses seven observed daily rows to dampen event-volume volatility without discarding each day's results. Crucially, these are seven *observed* days, not always seven consecutive calendar days, because missing days are not filled in this query.

**ROWS versus RANGE:** If two records have the same ordering value, `ROWS` counts physical rows and its cumulative total can advance one peer at a time; `RANGE` with the default peer-inclusive frame covers all rows sharing the sort value together. Grouping to one row per calendar date avoids duplicate-date peers in the chosen daily calculation.

**Gaps:** `LAG` finds intervals between consecutive reaction timestamps for each post, and an outer query selects intervals of at least 30 days. The result shows gaps *between observed events*, not proven creator inactivity. A gap might reflect low demand, visibility changes, missing ingestion, or other recording limitations. Check post status, activity logs and event pipeline completeness before deciding which interpretation applies. The executed gap query returned **50** intervals of at least 30 days. The longest displayed was for **Post 9**, between **January 5, 2023 14:18** and **April 28, 2023 04:16** (about **112 days 14 hours**). A gap between reactions is not proof that the producer stopped posting, nor proof of data loss; neither explanation can be established without additional posting and ingestion evidence.

## Task 6.3 — Reporting patterns

**Top three:** The executed query returned **39 rows**, three for each of the 13 posts with recorded reactions. Post 2's highest-dwell event had **47,810 ms** and Post 1's had **29,070 ms**. An engagement-review panel could surface three highest-dwell reaction events per post. Three is a manageable investigation shortlist with more context than one outlier and less noise than ten. `ROW_NUMBER` breaks a tie at third place using `like_id`, so no producer returns more than three rows. `FIRST_VALUE` repeats that producer's maximum dwell on each selected row. A different policy using `RANK` would retain all ties and could return more than three.

**Month-over-month:** The monthly series reports reaction volume, spam removals, spam-removal percentage, prior-month values and changes. It fills every month from the first observed event to the last, so a missing month is not mistaken for an adjacent month. A missing or zero-denominator month produces NULL rather than a manufactured failure rate. A major change could reflect volume mix, moderation policies or actual reaction quality; leaders should validate event counts, definitions and sample size before intervention.

**Observed 2023 month-by-month results (executed in pgAdmin):**

| Month | Reactions | Spam removals | Rate |
|---|---:|---:|---:|
| Jan | 21 | 2 | 9.52% |
| Feb | 21 | 0 | 0.00% |
| Mar | 11 | 2 | 18.18% |
| Apr | 11 | 0 | 0.00% |
| May | 17 | 2 | 11.76% |
| Jun | 20 | 1 | 5.00% |
| Jul | 17 | 1 | 5.88% |
| Aug | 18 | 1 | 5.56% |
| Sep | 16 | 1 | 6.25% |
| Oct | 18 | 0 | 0.00% |
| Nov | 14 | 0 | 0.00% |
| Dec | 16 | 2 | 12.50% |
| **2023 total** | **200** | **12** | **6.00%** |

All 12 months had reactions (no missing months according to the result's `missing_month` column). The trend is **volatile, not consistently improving**: January was 9.52%, December 12.50%, a rise of 2.98 percentage points. Yet the first quarter was 4/53 = 7.55% compared with the fourth quarter at 2/48 = 4.17%. Small monthly denominators and December's rebound mean this is not convincing evidence of sustained improvement. A leader should investigate the December events and validate the underlying moderation decisions rather than overreact to a single month's rate.

## Reflection (150–250 words)

Window functions helped me answer a question that a grouped average could not: which individual reactions behaved differently from the other reactions on the same post? With GROUP BY, I can calculate the average dwell time of each post, but I lose the reaction IDs, their timestamps, and the original dwell-time measurements. I could join the aggregate back to the events, but that adds another step and more room for errors. With AVG OVER PARTITION BY, the event and its producer average appear on the same row, so the difference is easy to inspect.

The same idea applies to monitoring platform activity over time. A total number of reactions says how much engagement the dataset contains, but not when that engagement accumulated or when activity slowed. A running SUM makes the progression visible; LAG adds context from the previous event, and a moving average helps distinguish short-term noise from a more sustained change. Each method requires careful decisions about ordering and grouping. For example, a seven-row moving average is not necessarily seven calendar days if dates are missing. I also learned that a ranking function encodes a policy: tied producers may need equal rank, while a fixed-size review panel may need a deterministic tie-breaker. The SQL should reflect that product decision rather than treating the ranking as neutral.
