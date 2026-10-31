-- 12_failure_modes.sql
-- Purpose: regroup issues by failure mode instead of product label, so one operational failure
-- that the CFPB form splits across Credit card, Checking, Prepaid and Money transfer shows up as one number
-- The grouping is an analyst judgment, shown in full in the CASE below
-- Windows: last 11m is Sep 2025 to Jul 2026, prior 11m is Sep 2023 to Jul 2024, two years apart
-- Surge-flagged rows are already out of the outcomes view

CREATE OR REPLACE VIEW modes AS
SELECT o.*,
  CASE
    WHEN product = 'Credit card' AND issue = 'Problem with a purchase shown on your statement'
      THEN 'Disputes and unauthorized transactions'
    WHEN product = 'Prepaid card' AND issue = 'Problem with a purchase or transfer'
      THEN 'Disputes and unauthorized transactions'
    WHEN product = 'Checking or savings account'
      AND issue = 'Problem with a lender or other company charging your account'
      AND sub_issue = 'Transaction was not authorized'
      THEN 'Disputes and unauthorized transactions'
    WHEN product = 'Checking or savings account' AND issue = 'Managing an account'
      AND sub_issue = 'Problem using a debit or ATM card'
      THEN 'Disputes and unauthorized transactions'
    WHEN product = 'Money transfer, virtual currency, or money service'
      AND issue = 'Unauthorized transactions or other transaction problem'
      THEN 'Disputes and unauthorized transactions'
    WHEN product = 'Money transfer, virtual currency, or money service' AND issue = 'Fraud or scam'
      THEN 'Fraud and scams'
    WHEN product = 'Checking or savings account' AND issue = 'Managing an account'
      AND sub_issue IN ('Deposits and withdrawals', 'Deposits or withdrawals', 'Problem accessing account')
      THEN 'Access to funds and holds'
    WHEN product = 'Money transfer, virtual currency, or money service'
      AND issue IN ('Trouble accessing funds in your mobile or digital wallet',
                    'Money was not available when promised',
                    'Managing, opening, or closing your mobile wallet account')
      THEN 'Access to funds and holds'
    WHEN product = 'Checking or savings account' AND issue = 'Managing an account'
      AND sub_issue IN ('Problem making or receiving payments', 'Funds not handled or disbursed as instructed')
      THEN 'Debits and payments gone wrong'
    WHEN product = 'Checking or savings account'
      AND issue = 'Problem with a lender or other company charging your account'
      AND (sub_issue LIKE 'Money was taken%' OR sub_issue LIKE '%stop withdrawals%')
      THEN 'Debits and payments gone wrong'
    WHEN product = 'Money transfer, virtual currency, or money service' AND issue = 'Other transaction problem'
      THEN 'Unclassified transaction problems'
    ELSE 'All other issues'
  END AS mode
FROM outcomes o;

-- 1. Failure modes: volume, two-year growth with and without Block and Zelle, share, outcomes
WITH b AS (
  SELECT mode,
    COUNT(*) FILTER (WHERE date_received >= DATE '2025-09-01') AS last_11m,
    COUNT(*) FILTER (WHERE date_received < DATE '2024-08-01') AS prior_11m,
    COUNT(*) FILTER (WHERE date_received >= DATE '2025-09-01'
                       AND company NOT IN ('Block, Inc.', 'Early Warning Services, LLC')) AS last_xb,
    COUNT(*) FILTER (WHERE date_received < DATE '2024-08-01'
                       AND company NOT IN ('Block, Inc.', 'Early Warning Services, LLC')) AS prior_xb,
    ROUND(100.0 * AVG(got_relief::INT) FILTER (WHERE date_received >= DATE '2025-09-01'), 1) AS relief_pct,
    ROUND(100.0 * AVG(poor_outcome::INT) FILTER (WHERE date_received >= DATE '2025-09-01'), 1) AS poor_pct
  FROM modes GROUP BY mode
)
SELECT mode, last_11m, prior_11m,
       ROUND(100.0 * (last_11m - prior_11m) / NULLIF(prior_11m, 0), 1) AS growth_all,
       ROUND(100.0 * (last_xb - prior_xb) / NULLIF(prior_xb, 0), 1) AS growth_xb,
       ROUND(100.0 * last_11m / SUM(last_11m) OVER (), 1) AS share_pct,
       relief_pct, poor_pct
FROM b ORDER BY last_11m DESC;

-- 2. Who generates disputes and unauthorized complaints, and how each company resolves them
SELECT SUBSTR(m.company, 1, 28) AS company_short, COALESCE(cg.company_group, 'Other') AS grp,
       COUNT(*) AS complaints,
       ROUND(100.0 * AVG(m.got_relief::INT), 1) AS relief_pct,
       ROUND(100.0 * AVG(m.poor_outcome::INT), 1) AS poor_pct
FROM modes m LEFT JOIN company_groups cg ON m.company = cg.company
WHERE m.mode = 'Disputes and unauthorized transactions' AND m.date_received >= DATE '2025-09-01'
GROUP BY 1, 2
HAVING COUNT(*) >= 400
ORDER BY complaints DESC
LIMIT 15;

-- 3. Mode mix as a share of each group's complaints, last 11 months
WITH g AS (
  SELECT m.mode,
    CASE WHEN m.company LIKE 'Chime%' THEN 'Chime'
         WHEN cg.company_group = 'Bank' THEN 'Banks'
         WHEN cg.company_group = 'Fintech' AND m.company <> 'Block, Inc.' THEN 'Other fintech'
    END AS grp
  FROM modes m LEFT JOIN company_groups cg ON m.company = cg.company
  WHERE m.date_received >= DATE '2025-09-01'
),
c AS (
  SELECT mode,
    COUNT(*) FILTER (WHERE grp = 'Chime') AS chime,
    COUNT(*) FILTER (WHERE grp = 'Banks') AS banks,
    COUNT(*) FILTER (WHERE grp = 'Other fintech') AS other_fintech
  FROM g GROUP BY mode
)
SELECT mode, chime, ROUND(100.0 * chime / SUM(chime) OVER (), 1) AS chime_pct,
       banks, ROUND(100.0 * banks / SUM(banks) OVER (), 1) AS banks_pct,
       other_fintech, ROUND(100.0 * other_fintech / SUM(other_fintech) OVER (), 1) AS other_fintech_pct
FROM c ORDER BY chime DESC;

-- 4. Money transfer by sub-product without Block and Zelle
SELECT SUBSTR(issue, 1, 36) AS issue_short, SUBSTR(sub_product, 1, 30) AS sub_product_short,
       COUNT(*) FILTER (WHERE date_received >= DATE '2025-09-01') AS last_11m,
       COUNT(*) FILTER (WHERE date_received < DATE '2024-08-01') AS prior_11m
FROM modes
WHERE product = 'Money transfer, virtual currency, or money service'
  AND company NOT IN ('Block, Inc.', 'Early Warning Services, LLC')
  AND mode IN ('Fraud and scams', 'Unclassified transaction problems', 'Disputes and unauthorized transactions')
GROUP BY 1, 2
HAVING COUNT(*) FILTER (WHERE date_received >= DATE '2025-09-01') >= 300
ORDER BY issue_short, last_11m DESC;
