-- 03_scope.sql
-- Purpose: flag complaints that are really credit reporting, so analysis can exclude them.
-- Why: credit bureaus are not neobank peers, and credit-report issues filed under
--      in-scope products (mostly Credit card) are a bureau problem, not a product problem.
-- Output: complaints_flagged (all rows plus two flags), complaints_scoped (rows kept)

CREATE OR REPLACE TABLE complaints_flagged AS
SELECT *,
  company IN ('EQUIFAX, INC.',
              'TRANSUNION INTERMEDIATE HOLDINGS, INC.',
              'Experian Information Solutions Inc.') AS is_bureau,
  (issue ILIKE '%report%' OR issue ILIKE '%credit score%'
   OR issue ILIKE '%investigation%' OR issue ILIKE '%fraud alert%'
   OR issue ILIKE '%identity theft%' OR issue ILIKE '%monitoring%') AS is_credit_report_issue
FROM complaints;

-- Surge flag: Jan 15-20, 2025 spike (approximate; includes some normal-day volume)
CREATE OR REPLACE TABLE complaints_scoped AS
SELECT * EXCLUDE (is_bureau, is_credit_report_issue),
  (date_received BETWEEN DATE '2025-01-15' AND DATE '2025-01-20'
   AND company IN ('Block, Inc.', 'Early Warning Services, LLC',
                   'NAVY FEDERAL CREDIT UNION', 'CAPITAL ONE FINANCIAL CORPORATION')
   AND issue IN ('Other transaction problem',
                 'Problem caused by your funds being low',
                 'Managing an account')) AS is_surge_event
FROM complaints_flagged
WHERE NOT is_bureau AND NOT is_credit_report_issue;

-- Check: surge rows and monthly volume without them
SELECT COUNT(*) AS rows, COUNT(*) FILTER (WHERE is_surge_event) AS surge_rows
FROM complaints_scoped;

-- Check: how much was excluded
SELECT COUNT(*) AS total,
       SUM(is_bureau::INT) AS bureau_rows,
       SUM(is_credit_report_issue::INT) AS credit_issue_rows,
       SUM((NOT is_bureau AND NOT is_credit_report_issue)::INT) AS kept
FROM complaints_flagged;
