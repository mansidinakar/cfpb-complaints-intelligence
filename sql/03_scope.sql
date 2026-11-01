-- 03_scope.sql
-- Purpose: flag complaints to leave out of trend analysis and build the scoped table
-- Flags: is_bureau (credit bureaus), is_credit_report_issue, is_surge_event
-- is_surge_event covers three anomalies:
--   1. Block and Early Warning Services (Zelle), Jan 13 to Aug 31 2025, a complaint campaign
--      driven by social media influencers as reported by Consumer Reports
--   2. Any other company whose Jan 13 to Jan 31 2025 volume was over 500 and over 3x its
--      December 2024 volume, which catches the Capital One vendor outage
--   3. Chime, Block and Early Warning Services complaints in Oct 2025 filed as Money transfer,
--      Other transaction problem. The narrative test found 52 to 68 percent near-duplicates
--      against 3 percent for all other companies that month. The cause was not found
-- Flagged rows are kept in the table, not deleted

DROP VIEW IF EXISTS modes;
DROP VIEW IF EXISTS outcomes;
DROP VIEW IF EXISTS analysis;

CREATE OR REPLACE TABLE spike_companies AS
SELECT company
FROM complaints
WHERE date_received BETWEEN DATE '2024-12-01' AND DATE '2025-01-31'
GROUP BY company
HAVING COUNT(*) FILTER (WHERE date_received BETWEEN DATE '2025-01-13' AND DATE '2025-01-31') > 500
   AND COUNT(*) FILTER (WHERE date_received BETWEEN DATE '2025-01-13' AND DATE '2025-01-31')
     > 3 * COUNT(*) FILTER (WHERE date_received BETWEEN DATE '2024-12-01' AND DATE '2024-12-31');

CREATE OR REPLACE TABLE complaints_flagged AS
SELECT *,
  company IN ('EQUIFAX, INC.',
              'TRANSUNION INTERMEDIATE HOLDINGS, INC.',
              'Experian Information Solutions Inc.') AS is_bureau,
  (issue ILIKE '%report%' OR issue ILIKE '%credit score%'
   OR issue ILIKE '%investigation%' OR issue ILIKE '%fraud alert%'
   OR issue ILIKE '%identity theft%' OR issue ILIKE '%monitoring%') AS is_credit_report_issue
FROM complaints;

CREATE OR REPLACE TABLE complaints_scoped AS
SELECT * EXCLUDE (is_bureau, is_credit_report_issue),
  (
    (company IN ('Block, Inc.', 'Early Warning Services, LLC')
       AND date_received BETWEEN DATE '2025-01-13' AND DATE '2025-08-31')
    OR
    (company IN (SELECT company FROM spike_companies)
       AND date_received BETWEEN DATE '2025-01-13' AND DATE '2025-01-31')
    OR
    ((company LIKE 'Chime%' OR company IN ('Block, Inc.', 'Early Warning Services, LLC'))
       AND date_received BETWEEN DATE '2025-10-01' AND DATE '2025-10-31'
       AND product = 'Money transfer, virtual currency, or money service'
       AND issue = 'Other transaction problem')
  ) AS is_surge_event
FROM complaints_flagged
WHERE NOT is_bureau AND NOT is_credit_report_issue;
