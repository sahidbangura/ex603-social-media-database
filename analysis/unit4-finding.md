# Leadership Finding — Social Media Reaction Spam Removals

**To:** Trust and Data leadership, Creator Monetization, Regional Operations  
**Subject:** Verified failure rate and producers warranting investigation  
**Scope:** All 200 reactions from the supplied 2023 reference dataset, not current-quarter production data.

## Findings

The reference dataset contains **200 reactions**, of which **12 were removed for spam**, a **6.00% spam-removal rate**. There were 34 removals of all reasons (17.00%); 22 of those were for other reasons, including user requests, duplicate reactions, and policy violations. These must not be mislabeled as spam. The earlier dashboard's estimate that roughly half of all events failed is inconsistent with this sample and failure definition. Since the original dashboard SQL was not supplied, this analysis cannot identify precisely what caused its erroneous figure.

| Post identifier | Reactions | Spam removals | Spam rate | Investigation priority |
|---|---:|---:|---:|---|
| **2** | 16 | 3 | **18.75%** | Highest spam-removal count and elevated rate |
| **3** | 13 | 2 | **15.38%** | Second-highest count and elevated rate |
| **1** | 11 | 1 | **9.09%** | Lower-priority validation candidate |

Posts 2 and 3 account for **5 of 12 spam removals (41.67%)** but only **29 of 200 reactions (14.50%)**. Post 4 has one failure in six reactions (16.67%) but falls below the 10-reaction screening threshold. These small samples indicate areas for inquiry, not proof of misconduct.

## Recommended next steps

The Trust and Safety and creator-monetization teams should inspect reaction-level moderation reasons, client regions and timestamps for posts 2 and 3; verify the official failure definition and the reporting denominator; and compare rates across a longer, more recent period. **No new payout decision should be made solely from this 2023 educational dataset.** A validated current-quarter calculation should inform any future decisions.
