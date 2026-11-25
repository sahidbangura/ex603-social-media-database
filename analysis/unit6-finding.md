# Unit 6 Leadership Closing Memo — Draft pending monthly verification

**Audience:** Trust and Safety, Creator Operations, platform leadership  
**Dataset:** Instructor-provided 2023 sample in `ex603_data`; not current production or next-quarter telemetry.

## Is the failure problem getting better or worse?

**Not yet established.** We verified in Unit 4 that 12 of 200 reactions were removed for the reason `Spam detected` (6.00% overall). That full-period percentage is **not** a time trend. The monthly failure-rate and prior-month comparison query in `queries/unit6/q6_3.sql` must be run and its actual results recorded here.

**Evidence to insert after execution:** monthly reaction counts, monthly spam removals, monthly failure percentages, and whether any months have no events. Discuss both changes in percentage points and denominators. Do not extrapolate from the small historical sample to future performance.

## What should the team do next quarter?

1. **Establish reliable monitoring.** Publish a monthly spam-removal metric with a fixed definition and denominators, plus rolling event counts and confidence/small-sample warnings. Validate missing months and ingestion integrity.
2. **Review high-failure posts, not just percentages.** Posts 2 and 3 had 3/16 (18.75%) and 2/13 (15.38%) spam removals, respectively, in the historical data. Investigate the events and moderation decisions before taking action.
3. **Separately address zero-engagement posts.** Posts 14 and 15 have no recorded reactions. Check visibility, exposure and tracking, then offer appropriate creator support. Lack of reaction records does not prove the posts were never viewed or published.
4. **Reassess with fresh data.** Compare a new quarter to a validated baseline, accounting for traffic volume, changing moderation policy and the possibility of random variation.

## Evidence references

- `queries/unit4/q4_2.sql`: full-period failures and high-volume baseline.
- `queries/unit5/q5_2.sql`: producers with no events, outer join validation.
- `queries/unit6/q6_3.sql`: monthly comparison, missing-month check (**execution pending**).

**Submission gate:** Replace the provisional trend statement above with observed results before submitting this memo as the final conclusion.
