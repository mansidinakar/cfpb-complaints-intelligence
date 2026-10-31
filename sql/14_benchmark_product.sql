-- 14_benchmark_product.sql
-- Purpose: compare Chime with banks inside the same product and failure mode, then re-weight banks to Chime's mix
-- This replaces the mode-only comparison in 13_benchmark.sql, which does not adjust for product
-- Window: Sep 2025 to Jul 2026. Companies label their own responses, so gaps are observations, not proof of service quality

-- 1. Cells: relief rate by product and failure mode, Chime vs banks
CREATE OR REPLACE TABLE chime_vs_banks AS
WITH g AS (
  SELECT mode, product, got_relief,
    CASE WHEN company LIKE 'Chime%' THEN 'Chime'
         WHEN company IN (SELECT company FROM company_groups WHERE company_group = 'Bank') THEN 'Banks'
    END AS grp
  FROM modes WHERE date_received >= DATE '2025-09-01'
)
SELECT product, mode,
  COUNT(*) FILTER (WHERE grp = 'Chime') AS chime_n,
  AVG(got_relief::INT) FILTER (WHERE grp = 'Chime') AS chime_rel,
  COUNT(*) FILTER (WHERE grp = 'Banks') AS banks_n,
  AVG(got_relief::INT) FILTER (WHERE grp = 'Banks') AS banks_rel
FROM g WHERE grp IS NOT NULL GROUP BY product, mode;

-- 2. Banks re-weighted to Chime's product and mode mix
SELECT SUM(chime_n) AS chime_complaints,
       ROUND(100.0 * SUM(chime_n * chime_rel) / SUM(chime_n), 1) AS chime_relief_pct,
       ROUND(100.0 * SUM(chime_n * banks_rel) / SUM(chime_n), 1) AS banks_at_chime_mix_pct
FROM chime_vs_banks WHERE chime_n >= 30 AND banks_n >= 30;
