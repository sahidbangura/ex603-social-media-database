# Unit 5 Screenshot Evidence — Capture Checklist

**Status: screenshots still need to be captured in pgAdmin.** The assignment requires an original, full, uncropped screenshot showing the entire executed SQL statement and its legible result **in the same image**. Earlier screenshots verified individual results but most show only the bottom of long queries, so they do not meet that standard. Do not reconstruct, composite, or claim they do.

Connect to `ex603_data`. Run each statement **individually**, selected in the editor (or in a fresh tab) so the displayed result corresponds to the SQL visible in the capture. Use pgAdmin's maximize/hide-panels options, a smaller editor font, and a large screen if needed.

Suggested screenshot filenames:

- `5_1_three_table_join.png`
- `5_1_junction_tech.png`
- `5_1_junction_posts_2_3.png`
- `5_1_self_join.png`
- `5_2_left_join.png`
- `5_2_inner_join.png`
- `5_2_exclusion_counts.png`
- `5_2_missing_posts.png`
- `5_2_right_join.png`
- `5_2_join_equivalence_check.png`
- `5_2_full_outer_join.png`
- `5_2_orphan_check.png`
- `5_2_not_exists.png`
- `5_2_except.png`
- `5_2_approach_comparison.png`
- `5_3_cross_join_sample.png`
- `5_3_cross_join_counts.png`
- `5_3_explain_full_plan.png`

Use the queries stored in `queries/unit5/q5_1.sql`, `q5_2.sql`, and `q5_3.sql`. Query comments explain which requirement each statement answers.

## Known results from observed pgAdmin runs

- Three-table event join: 200 rows
- Posts 2 and 3 have the common hashtag `tech`
- Same-country post self-join: 5 comparisons
- Producers: 15 via LEFT / RIGHT versus 13 via INNER; excluded: posts 14 and 15
- NOT EXISTS and EXCEPT: both identify 14 and 15
- CROSS JOIN: 5 hashtags × 28 media rows = 140 rows
- EXPLAIN: Hash Join, Nested Loop, Seq Scan, Memoize, `posts_pkey` Index Scan and Sort, 13 lines

**Still to verify with new executions:** direct INNER JOIN report, exact LEFT/RIGHT row-set equality check, orphan check, standalone NOT EXISTS/EXCEPT, theme-wide 'tech' tag query, CROSS JOIN sample. Capture the full EXPLAIN plan on one screen.

## Screenshot audit (November 9, 2026)

Fifteen original pgAdmin captures were reviewed. The complete orphan-check capture showed zero orphaned reactions and is suitable for submission. Fourteen other captures show only part of the SQL statement or execution plan and need replacement for the professor's uncropped full-query-and-result requirement. The original capture files have been packaged separately for manual GitHub upload; **they have not yet been uploaded into this GitHub directory**. Do not confuse this README checklist with actual screenshot files.

The LEFT-vs-RIGHT and RIGHT-vs-LEFT EXCEPT checks both returned zero differences. The orphaned reaction check returned zero.
