# CFPB Complaints Intelligence

**Which complaint issues should a fintech or neobank fix first?** This project turns public CFPB consumer complaint data into a prioritized product recommendation using SQL, Python text analysis and a Tableau dashboard.

## The scenario

You are a product analyst at a hypothetical digital bank or payments app. Leadership asks: which complaint issues should we fix first? You use public complaints about peer companies as market evidence.

## Questions this project answers

1. How is complaint volume trending by product and issue?
2. Which issues have the worst outcomes (no relief, untimely response)?
3. How do fintech peers compare with large banks?
4. What themes inside complaint narratives sit behind the top issues that the structured issue label hides?
5. Which issues are rising fastest?
6. Which three issues should a neobank fix first, with what product change and success metric?

## Status

- [x] Phase 0: Setup
- [x] Phase 1: Data collection and profiling
- [ ] Phase 2: SQL analysis (trends, rankings, outcomes, peer comparison, priority table)
- [ ] Phase 3: Python text analysis (TF-IDF and topic modeling on narratives)
- [ ] Phase 4: Tableau dashboard
- [ ] Phase 5: Recommendation memo

Key findings, dashboard link and memo will be added after Phases 2 to 5.

## Data and scope

**Sources.** CFPB Consumer Complaint Database (bulk CSV) for structured fields, and the CFPB Narratives Archive for complaint narratives. Complaint IDs match between the two.

**Window.** Complaints received Sept 1, 2023 to Aug 14, 2026. The window starts after the CFPB's Aug 24, 2023 complaint-form update, so one product and issue taxonomy applies throughout. Aug 14, 2026 is the date the CFPB stopped publishing narratives. August 2026 is a partial month.

**Products in scope.** Credit card; Checking or savings account; Money transfer, virtual currency, or money service; Prepaid card. Credit reporting, debt collection, mortgage, student loan, vehicle loan and payday products are excluded because they are not neobank products.

**Scope summary.**

| Step | Complaints |
| --- | --- |
| Complaints in window, four products | 605,225 |
| Credit bureau complaints (Equifax, Experian, TransUnion) | 52,511 |
| Credit-report issues under in-scope products | 62,834 |
| Excluded in total (the two overlap) | 72,210 |
| **Analysis set** | **533,015** |
| Of which flagged as Jan 15 to 20, 2025 surge window | 45,338 |

Excluded and surge rows are flagged in the data, not deleted.

**Peer groups.**

| Group | Companies | Complaints (in-scope products) |
| --- | --- | --- |
| Fintech | Block (Cash App), PayPal, Chime, SoFi, Robinhood, Coinbase, Wise, Remitly, MoneyLion, Dave | 117,229 |
| Bank benchmark | JPMorgan Chase, Bank of America, Wells Fargo, Capital One, Citibank | 196,342 |

Varo does not appear in the data. Chime appears under two entity names, both mapped to Fintech. Block accounts for 61,656 complaints, 52.6% of the fintech group, so group results are shown with and without it. Complaint counts are not normalized by customer base, so companies are compared on issue mix, not raw volume.

**Surge window.** Complaint volume spiked on Jan 15 to 20, 2025, driven by Block, Early Warning Services (Zelle), Navy Federal and Capital One. Results are shown with and without the flagged complaints. The underlying cause has not been verified.

**Narratives.** The bulk file has no narrative column, so narratives come from the Narratives Archive. Coverage varies by period: about 56 to 61% of in-scope complaints in Sept 2023 to Mar 2024, 23.5% in July 2026 and near zero in Aug 2026. The months in between will be measured when the remaining archive exports are loaded in Phase 3. Theme trends will use each theme's share of narratives, not raw counts.

## CFPB complaint-form changes

The CFPB periodically changes the products and issues on its complaint form, and the database keeps the labels consumers saw when they filed. These changes shaped the scope of this project.

| Change | Effective | Impact on this project |
| --- | --- | --- |
| Form update: product and issue options revised | Aug 24, 2023 | Window starts Sept 1, 2023 to avoid it |
| "Credit card or prepaid card" split into "Credit card" and "Prepaid card" | Aug 24, 2023 | Old name excluded by window |
| Checking or savings: sub-issue "Account opened as a result of fraud" renamed "Account opened without my consent or knowledge" | Aug 24, 2023 | None in window |
| Money transfer: new issue "Trouble accessing funds in your mobile or digital wallet"; "Debt settlement" moved out; money order and traveler's/cashier's check sub-products merged | Aug 24, 2023 | None in window |
| Payday product renamed; "Earned wage access" and "Other advances of future income" added | Aug 24, 2023 | None in window (product excluded from scope) |
| "Debanking" issue added to Checking or savings and Credit card | Oct 29, 2026 | After the window ends |

Sources: CFPB complaint form product and issue options, August 2023 and October 2026 updates.

## Repository structure

    cfpb-complaints-intelligence/
    ├── data/          # raw and processed data (not committed)
    ├── docs/          # recommendation memo and documentation
    ├── notebooks/     # Jupyter notebooks (loading, profiling, text analysis)
    ├── scripts/       # data preparation scripts
    ├── sql/           # analysis queries, numbered in run order
    └── tableau/       # dashboard notes and screenshots

SQL files, in run order:

- **01_profile.sql**: data profiling and anomaly checks
- **02_company_groups.sql**: fintech and bank peer groups
- **03_scope.sql**: credit-report and surge flags, scoped table

## Tools

SQL (DuckDB), Python (pandas, scikit-learn, matplotlib, Jupyter), Tableau Public, GitHub.

## How to reproduce

**Step 1.** Clone the repo and create a virtual environment:

    python3 -m venv venv
    source venv/bin/activate
    pip install duckdb pandas scikit-learn matplotlib jupyter

**Step 2.** Download the full complaint CSV ZIP from the [CFPB Consumer Complaint Database](https://www.consumerfinance.gov/data-research/consumer-complaints/) into data/raw/.

**Step 3.** Filter it to the project scope:

    python scripts/filter_bulk.py

**Step 4.** Open notebooks/01_load_and_profile.ipynb and run the cells to load the data into DuckDB and build the complaints, company_groups and complaints_scoped tables.

**Step 5.** Download the [CFPB Narratives Archive](https://www.consumerfinance.gov/foia-requests/foia-electronic-reading-room/cfpb-consumer-complaint-database-narratives-archive/) exports into data/raw/archive/ (needed from Phase 3).

## Limitations

- Complaints are not a statistical sample of consumer experience, and counts are not normalized by customer base.
- Narratives exist only for complaints where the consumer consented to publication, so themes describe that group.
- The CFPB stopped publishing narratives on Aug 14, 2026, which fixes the data cutoff.
- Excluded credit-report complaints and the Jan 2025 surge are flagged in the data, and results are shown with and without them where relevant.
