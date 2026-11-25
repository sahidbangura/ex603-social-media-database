# Unit 6 Leadership Closing Memo — Verified 2023 Sample

**Audience:** Trust and Safety, Creator Operations, platform leadership  
**Dataset:** Instructor-provided 2023 sample in `ex603_data`; not current production or next-quarter telemetry.

## Is the failure problem getting better or worse?

**Answer: the 2023 sample does not show a sustained improvement; the monthly spam-removal rate fluctuates sharply.** The executed month-over-month query found **12 spam removals among 200 reactions (6.00%)** in 2023. It includes all 12 calendar months, with no missing-month flags.

January: 2/21 = **9.52%**; March: 2/11 = **18.18%**; October and November: **0 removals** in 18 and 14 reactions; December: 2/16 = **12.50%**. December therefore ended **2.98 percentage points above January**, and rebounded after two zero-removal months.

A broader comparison gives a different but compatible view: **Q1 = 4/53 = 7.55%**, **Q4 = 2/48 = 4.17%**. Q4's lower aggregate rate is encouraging, but there are few failures and substantial month-to-month swings. It would be inaccurate to claim the problem was consistently solved or to extrapolate this educational sample to current-quarter operations.

| Period | Reactions | Spam removals | Spam-removal rate |
|---|---:|---:|---:|
| 2023 full year | 200 | 12 | 6.00% |
| Q1 (Jan–Mar) | 53 | 4 | 7.55% |
| Q4 (Oct–Dec) | 48 | 2 | 4.17% |
| December alone | 16 | 2 | 12.50% |

## What should the team do next quarter?

1. **Investigate December's increase and establish reliable monitoring.** Review the two December spam removals and publish a monthly spam-removal metric with a fixed definition and denominators, plus rolling event counts and confidence/small-sample warnings. Validate missing months and ingestion integrity.
2. **Review high-failure posts, not just percentages.** Posts 2 and 3 had 3/16 (18.75%) and 2/13 (15.38%) spam removals, respectively, in the historical data. Investigate the events and moderation decisions before taking action.
3. **Separately address zero-engagement posts.** Posts 14 and 15 have no recorded reactions. Check visibility, exposure and tracking, then offer appropriate creator support. Lack of reaction records does not prove the posts were never viewed or published.
4. **Reassess with fresh data.** Compare a new quarter to a validated baseline, accounting for traffic volume, changing moderation policy and the possibility of random variation.

## Evidence references

- `queries/unit4/q4_2.sql`: full-period failures and high-volume baseline.
- `queries/unit5/q5_2.sql`: producers with no events, outer join validation.
- `queries/unit6/q6_3.sql`: executed monthly comparison showing all 12 months; separate missing-month audit SQL is supplied.

**Interpretation limit:** These conclusions apply only to the supplied 2023 reference data, not today's platform.
