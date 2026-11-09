# Leadership Memo — Reaction Quality and Never-Engaged Posts

**To:** Trust and Safety, Creator Operations, Platform Leadership
**Subject:** Separate actions for high spam-removal rates and posts without reactions
**Data scope:** Instructor-provided 2023 social media sample; conclusions are not current production findings.

## Findings

The dataset contains 200 reactions across 13 of 15 posts. A reaction is counted as a spam failure only when its status is `removed` and the removal reason is `Spam detected`. Twelve events satisfy this definition (6.00%).

**Higher spam-removal rates:** Post 2 has 3 spam removals among 16 reactions (**18.75%**); Post 3 has 2 among 13 (**15.38%**). Together they account for 5 of the 12 identified spam removals. Both posts share the `tech` hashtag, but that association does not establish why the events were removed. The samples are too small to establish wrongdoing.

**No recorded reactions:** Posts **14 and 15** have no matching records in the `likes` table. They disappear from a report built only with INNER JOIN, but appear in LEFT or RIGHT JOIN reports. No reaction rows does not, by itself, establish a failure to publish, lack of views, or creator abandonment.

## Recommended actions

1. **Investigate quality exceptions (posts 2 and 3):** Ask Trust and Safety to review the underlying moderation decisions, timestamps, reaction origins and consistency of spam classification. Compare against a larger, more recent sample and assess whether corrective action is warranted only after validation.
2. **Investigate participation gaps (posts 14 and 15):** Ask Creator Operations to inspect posting and visibility status, discovery placement, date published, exposure metrics and event tracking. Offer onboarding or distribution support if these checks indicate a genuine engagement problem rather than missing data.

## Reporting improvement

Add a producer-completeness view that begins with all posts and LEFT JOINs their reaction counts. Show `0 reactions` explicitly, separate this from reaction-quality alerts, and let leadership drill into individual events. Avoid making policy or payout decisions using only this historical educational dataset.
