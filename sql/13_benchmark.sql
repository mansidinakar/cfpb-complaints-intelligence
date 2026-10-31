-- 13_benchmark.sql
-- Purpose: compare relief rates across companies on the same failure-mode mix
-- Method: direct standardization. Each group's relief rate in each failure mode is weighted by
-- the banks' mode mix, so differences in what customers complain about drop out
-- Window: Sep 2025 to Jul 2026
-- Companies label their own responses, so this is an observation, not proof of service quality

CREATE OR REPLACE TABLE benchmark_by_mode AS
WITH g AS (
  SELECT mode, got_relief,
    CASE WHEN company LIKE 'Chime%' THEN 'Chime'
         WHEN company LIKE 'Paypal%' THEN 'PayPal'
         WHEN company = 'Block, Inc.' THEN 'Block'
         WHEN company IN (SELECT company FROM company_groups WHERE company_group = 'Bank') THEN 'Banks'
    END AS grp
  FROM modes WHERE date_received >= DATE '2025-09-01'
)
SELECT grp, mode, COUNT(*) AS n, AVG(got_relief::INT) AS relief
FROM g WHERE grp IS NOT NULL GROUP BY grp, mode;

CREATE OR REPLACE TABLE benchmark_rates AS
WITH weights AS (
  SELECT mode, n * 1.0 / SUM(n) OVER () AS w FROM benchmark_by_mode WHERE grp = 'Banks'
)
SELECT r.grp, SUM(r.n) AS complaints,
       ROUND(100.0 * SUM(r.n * r.relief) / SUM(r.n), 1) AS raw_relief_pct,
       ROUND(100.0 * SUM(w.w * r.relief), 1) AS relief_at_bank_mix_pct
FROM benchmark_by_mode r JOIN weights w USING (mode)
GROUP BY r.grp;

-- Result: raw and mix-adjusted relief rate by group
SELECT * FROM benchmark_rates ORDER BY relief_at_bank_mix_pct DESC;
