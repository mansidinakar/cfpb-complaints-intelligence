# CFPB Complaints Intelligence

**Which complaint failures should a fintech or neobank fix first?** Real CFPB complaint data, analyzed with SQL (DuckDB), Python text analysis and a Tableau dashboard, ending in a prioritized product recommendation.

## Key findings (Phase 2, structured data)

Growth compares Sep 2025 to Jul 2026 with Sep 2023 to Jul 2024, two years apart, so the Jan 2025 anomalies sit in neither window. Overall complaint volume grew 77.9% (68.1% without Block and Zelle).

| Failure mode | Complaints | Share | Growth | Growth without Block and Zelle | Relief rate |
| --- | --- | --- | --- | --- | --- |
| Disputes and unauthorized transactions | 56,175 | 29.6% | +115% | +106% | 23.3% |
| Access to funds and holds | 27,430 | 14.4% | +86% | +73% | 17.3% |
| Debits and payments gone wrong | 10,586 | 5.6% | +105% | +99% | 14.5% |
| Fraud and scams | 10,320 | 5.4% | +98% | +67% | 10.3% |
| Unclassified transaction problems | 6,798 | 3.6% | +175% | +107% | 10.3% |
| All other issues | 78,751 | 41.4% | +48% | +44% | 22.4% |

1. **One failure, four product labels.** Disputes and unauthorized transactions appear under credit card (26,721), checking (21,496), money transfer (5,938) and prepaid (2,020). Outside credit cards the mode has 29,454 complaints, up 122%. Grouping by failure mode shows a problem that product-level rankings split into pieces.
2. **Chime resolves fewer complaints, and the mix of complaints does not explain it.** Relief rate in Sep 2025 to Jul 2026: Chime 7.6%, banks 25.7%, PayPal 38.5%. At the banks' complaint mix, Chime's rate is 8.6%, so mix explains about 1 of the 18 points.
3. **Chime's complaints concentrate in disputes and debits.** Disputes and unauthorized transactions are 41.9% of Chime's complaints, against 31.4% for banks and 27.1% for other fintechs. Debits and payments gone wrong are 10.6% vs 6.1% for banks.
4. **The gap holds in every failure mode.**

| Relief rate | Chime | Banks | PayPal |
| --- | --- | --- | --- |
| Disputes and unauthorized transactions | 7.8% | 29.8% | 45.9% |
| Access to funds and holds | 9.3% | 20.9% | 33.3% |
| Debits and payments gone wrong | 7.8% | 16.8% | 35.0% |
| Fraud and scams | 3.3% | 8.9% | 39.9% |

5. **Block's relief rate is 0.1%**, which is consistent with the complaint campaign described below, so Block is kept out of the conclusions.

**Provisional priorities (root causes come from complaint narratives in Phase 3):**

1. Disputes and unauthorized transactions
2. Access to funds and holds
3. Debits and payments gone wrong

**Watch list:** Fraud and scams has the worst outcomes at scale, but without Block and Zelle it grows no faster than overall volume. Unclassified transaction problems grow fast, but the CFPB issue label has no sub-issues, so it cannot be acted on until the narratives show what it contains.

## Status

- [x] Phase 0: Setup
- [x] Phase 1: Data collection and profiling
- [x] Phase 2: SQL analysis
- [ ] Phase 3: Python text analysis (root causes from narratives)
- [ ] Phase 4: Tableau dashboard
- [ ] Phase 5: Recommendation memo

## The scenario

You are a product analyst at a hypothetical digital bank or payments app. Leadership asks: which complaint failures should we fix first? You use public complaints about peer companies as market evidence.

## Data and scope

**Sources.** CFPB Consumer Complaint Database (bulk CSV) for structured fields, and the CFPB Narratives Archive for complaint narratives. Complaint IDs match between the two.

**Window.** Complaints received Sept 1, 2023 to Aug 14, 2026. The window starts after the CFPB's Aug 24, 2023 complaint-form update, so one product and issue taxonomy applies throughout. Aug 14, 2026 is the date the CFPB stopped publishing narratives. August 2026 is a partial month and is left out of trend and growth analysis.

**Products in scope.** Credit card; Checking or savings account; Money transfer, virtual currency, or money service; Prepaid card. Credit reporting, debt collection, mortgage, student loan, vehicle loan and payday products are excluded because they are not neobank products.

**Scope summary.**

| Step | Complaints |
| --- | --- |
| Complaints in window, four products | 605,225 |
| Credit bureau complaints (Equifax, Experian, TransUnion) | 52,511 |
| Credit-report issues under in-scope products | 62,834 |
| Excluded in total (the two overlap) | 72,210 |
| **Analysis set** | **533,015** |
| Of which flagged as surge (see below) | 74,909 |

Excluded and surge rows are flagged in the data, not deleted.

**Peer groups** (complaints before exclusions).

| Group | Companies | Complaints |
| --- | --- | --- |
| Fintech | Block (Cash App), PayPal, Chime, SoFi, Robinhood, Coinbase, Wise, Remitly, MoneyLion, Dave | 117,229 |
| Bank benchmark | JPMorgan Chase, Bank of America, Wells Fargo, Capital One, Citibank | 196,342 |

Varo does not appear in the data. Chime appears under two entity names, both mapped to Fintech. Block accounts for 61,656 complaints, 52.6% of the fintech group.

## The January 2025 surge

The scoped data has 74,547 complaints in January 2025, against 11,584 in December 2024. Block (31,221) and Early Warning Services, which operates Zelle (16,722), account for most of the increase. Before that they averaged about 250 and 30 to 110 complaints a month.

- **Complaint campaign.** Consumer Reports reported that Zelle and Cash App complaints rose nearly 15-fold in early 2025 after social media influencers told followers to file complaints, with more than 61,000 filed in the first eight months of the year. The companies told Consumer Reports that most came from the influencers' content. The CFPB ordered Block to pay $175 million on Jan 16, 2025.
- **Capital One outage.** A mid-January 2025 outage at Capital One, caused by its vendor FIS Global, explains part of the remaining excess. The cause of the Navy Federal spike was not found.
- **Handling.** Block and Zelle complaints from Jan 13 to Aug 31, 2025, and the Jan 13 to 31 complaints of any other company whose volume more than tripled (Capital One and Navy Federal), are flagged and left out of growth and rankings.
- **Block after the campaign.** Block stayed at about 1,200 to 1,500 complaints a month, roughly 5x its old level. The structured data cannot say whether that is lingering campaign filing or real growth, so every ranking is also run without Block and Zelle.

Sources: [Consumer Reports](https://www.consumerreports.org/money/scams-fraud/cfpb-not-giving-money-to-people-scammed-on-zelle-cash-app-a9372236265/), [CFPB order against Block](https://www.consumerfinance.gov/enforcement/actions/block-inc/), [Fortune on the Capital One outage](https://fortune.com/article/capital-one-service-outage-january-2025-update).

## Method

- **Relief** means closed with monetary or non-monetary relief. **Poor outcome** means no relief or an untimely response. Complaints still in progress are excluded from outcome rates.
- **Failure modes** group CFPB issue and sub-issue labels by what went wrong. The grouping is analyst judgment, and the full definition is the CASE statement in 12_failure_modes.sql.
- **Fixability ratings** (10_fixability.sql) are analyst judgment, not data.
- **Sensitivity.** Issue-level priority scores were tested across 12 scenarios (six weight sets, with and without Block and Zelle). Only three issues stayed in the top five in at least 10 of the 12, and one of them has no sub-issues to act on, so the final analysis groups by failure mode.
- **Mix-adjusted benchmark.** Each company's relief rate in each failure mode is weighted by the banks' complaint mix, so differences in what customers complain about drop out.

## Narratives

The bulk file has no narrative column, so narratives come from the Narratives Archive. Coverage varies: about 56 to 61% of in-scope complaints in Sept 2023 to Mar 2024, 23.5% in July 2026 and near zero in Aug 2026. Other months are measured in Phase 3, and theme trends use each theme's share of narratives, not raw counts.

## CFPB complaint-form changes

The CFPB periodically changes the products and issues on its complaint form, and the database keeps the labels consumers saw when they filed.

| Change | Effective | Impact on this project |
| --- | --- | --- |
| Form update: product and issue options revised | Aug 24, 2023 | Window starts Sept 1, 2023 to avoid it |
| "Credit card or prepaid card" split into "Credit card" and "Prepaid card" | Aug 24, 2023 | Old name excluded by window |
| Checking or savings: sub-issue "Account opened as a result of fraud" renamed "Account opened without my consent or knowledge" | Aug 24, 2023 | None in window |
| Money transfer: new issue "Trouble accessing funds in your mobile or digital wallet"; "Debt settlement" moved out; money order and traveler's/cashier's check sub-products merged | Aug 24, 2023 | None in window |
| Payday product renamed; "Earned wage access" and "Other advances of future income" added | Aug 24, 2023 | None in window (product excluded from scope) |
| "Debanking" issue added to Checking or savings and Credit card | Oct 29, 2026 | After the window ends |

## Repository structure

    cfpb-complaints-intelligence/
    ├── data/          # raw and processed data (not committed)
    ├── docs/          # recommendation memo and documentation
    ├── notebooks/     # 01 load and profile, 02 SQL analysis
    ├── scripts/       # data preparation scripts
    ├── sql/           # analysis queries, numbered in run order
    └── tableau/       # dashboard notes and screenshots

SQL files, in run order:

- **01_profile.sql**: data profiling and anomaly checks
- **02_company_groups.sql**: fintech and bank peer groups
- **03_scope.sql**: credit-report and surge flags, scoped table
- **04_trend.sql**: monthly volume, month-over-month change, rolling average
- **05_top_issues.sql**: top issues per product
- **06_growth.sql**: one-year growth (superseded by the two-year method)
- **07_peer_compare.sql**: fintech vs bank issue mix
- **08_outcomes.sql**: relief and untimely rates
- **09_priority.sql**: issue-level priority score
- **10_fixability.sql**: fixability ratings (analyst judgment)
- **11_sensitivity.sql**: ranking stability across 12 scenarios
- **12_failure_modes.sql**: issues regrouped by failure mode
- **13_benchmark.sql**: mix-adjusted company comparison

## Tools

SQL (DuckDB), Python (pandas, scikit-learn, matplotlib, Jupyter), Tableau Public, GitHub.

## How to reproduce

1. Clone the repo and create a virtual environment:

        python3 -m venv venv
        source venv/bin/activate
        pip install duckdb pandas scikit-learn matplotlib jupyter

2. Download the full complaint CSV ZIP from the [CFPB Consumer Complaint Database](https://www.consumerfinance.gov/data-research/consumer-complaints/) into data/raw/.

3. Filter it to the project scope:

        python scripts/filter_bulk.py

4. Run notebooks/01_load_and_profile.ipynb to load the data into DuckDB and build the complaints and company_groups tables.

5. Run notebooks/02_sql_analysis.ipynb to build the scoped tables, run the analysis and export the aggregated CSVs for Tableau to data/processed/.

6. For Phase 3, download the [CFPB Narratives Archive](https://www.consumerfinance.gov/foia-requests/foia-electronic-reading-room/cfpb-consumer-complaint-database-narratives-archive/) exports into data/raw/archive/.

## Limitations

- Complaints are not a statistical sample of consumer experience, and counts are not normalized by customer base.
- Response labels are chosen by the companies, and "closed with explanation" does not mean a complaint was unfounded or mishandled. Relief-rate gaps are observations, not proof of worse service.
- Narratives exist only for complaints where the consumer consented to publication, so themes describe that group. The CFPB stopped publishing narratives on Aug 14, 2026, which fixes the data cutoff.
- The failure-mode grouping and the fixability ratings are analyst judgment.
- Block's complaint volume after the 2025 campaign cannot be classified as genuine or campaign-driven from structured data.
