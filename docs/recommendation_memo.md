# Which complaint failures should a neobank fix first?

**To:** Head of Product, Customer Operations (consumer fintech / neobank)
**From:** Mansi Dinakar
**Date:** November 2026
**Data:** CFPB Consumer Complaint Database, Sep 1 2023 to Aug 14 2026. Live dashboards: https://public.tableau.com/views/CFPBComplaintsIntelligence/Theproblem

## Recommendation

Fix three failure modes, in this order. The evidence is strongest for the first and weakest for the third.

| Priority | Failure mode | Share of complaints | Two-year growth* | Chime vs banks relief rate (checking) | Evidence |
|---|---|---|---|---|---|
| 1 | Disputes and unauthorized transactions | 29.8% | +106% | 7.8% vs 23.5% | Strong |
| 2 | Access to funds and holds | 14.5% | +73% | 9.1% vs 21.2% | Moderate |
| 3 | Debits and payments gone wrong | 5.6% | +99% | 7.8% vs 16.8% | Structured data only |

*Sep 2025 to Jul 2026 versus Sep 2023 to Jul 2024, excluding Block and Zelle. Overall complaint volume grew 68% on the same basis.

## Why this matters

I analyzed 533,015 complaints about credit cards, checking, money transfer and prepaid products. Disputes and unauthorized transactions are the largest named failure mode and one of the fastest growing. Complaints are growing, and the complaints that grow fastest are the ones where the consumer has lost money and is asking for it back.

Relief is the outcome that matters most. A consumer who gets monetary or non-monetary relief has had the problem fixed. Across the same product and failure mode, Chime closes 8.0% of complaints with relief. The five largest banks close 25.7%, or 21.2% once I re-weight the banks to Chime's product and failure-mode mix. Mix explains about 4.5 of the 17.7-point gap. A 13.2-point gap remains. Chime is below the banks in 11 of 12 segments I could compare.

## What the complaints say

I read 10 sampled narratives for each of 14 machine-found themes. A theme passed if 7 of 10 fit its label. Seven passed:

- **Disputes (four themes, 57.3% of that mode's narratives):** unauthorized debit card transactions with the claim denied; money taken from a checking account or ATM with no help; a charge disputed with a company after payment; merchant refund or non-delivery disputes.
- **Access to funds (two themes, 42.9% of that mode's narratives):** check deposits held with funds not available; accounts closed with funds hard to withdraw.
- **Wire transfers (one theme):** wire transfer problems with a recall requested.

No debits theme passed, so I do not claim to know why debits fail. That is why Priority 3 is a diagnostic step, not a product fix.

## What to do

1. **Disputes.** One dispute flow with in-app claim status, a written reason for every denial, and a one-step appeal. *Measure:* relief rate against the 23.5% benchmark, and appeals overturned.
2. **Access to funds.** Show the hold reason and release date at deposit, and release the balance on account closure on a stated schedule. *Measure:* hold-related contacts per 1,000 deposits, and days from closure to funds release.
3. **Debits and payments.** Review missing direct deposits and payment postings in internal logs before building a fix. *Measure:* failed or reversed payment rate, and direct deposit posting delay.

*Watch list:* fraud and scams. Relief is 10.3% and complaints have grown no faster than overall volume once Block and Zelle are excluded.

## How I kept the data honest

- **Two complaint surges removed.** A Block and Zelle campaign (Jan 13 to Aug 31 2025) and an October 2025 template wave inflated counts. In the campaign weeks, 77.6% of Block and Zelle narratives were near-duplicates, against 3.0% before and 3.7% for other companies. I flagged 76,420 complaints as surge and left them out of growth and relief figures.
- **Growth measured over two years,** not one, so the surge does not distort the trend.
- **Benchmark adjusted for mix.** Chime is compared with banks in the same product and failure mode, then banks are re-weighted to Chime's mix.
- **Sensitivity checked** across 12 scenarios.

## Limits

- Complaint counts are not adjusted for customer base, and companies label their own responses. The gaps are observations, not proof of worse service.
- Failure modes are my own grouping of CFPB issue labels. Fixes and priority order are analyst judgment.
- Narratives exist only where the consumer consented to publication, so themes describe that group. The CFPB stopped publishing narratives on Aug 14 2026.
- Themes were modeled before the October 2025 wave was flagged, so the unclassified theme shares include some of it.

Full method, SQL, Python and numbers: https://public.tableau.com/views/CFPBComplaintsIntelligence/Theproblem `cfpb-complaints-intelligence`.
