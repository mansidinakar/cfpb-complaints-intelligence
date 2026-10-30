-- 06_growth.sql
-- Purpose: which issues are growing fastest
-- Compares the last 12 full months (Aug 2025 to Jul 2026) with the 12 before (Aug 2024 to Jul 2025)
-- Surge rows excluded. Issues with fewer than 200 complaints in the prior year are skipped as too small

-- 1. Fastest growing issues by percent
WITH w AS (
  SELECT product, issue,
         COUNT(*) FILTER (WHERE date_received >= DATE '2025-08-01') AS last_12m,
         COUNT(*) FILTER (WHERE date_received >= DATE '2024-08-01'
                            AND date_received <  DATE '2025-08-01') AS prior_12m
  FROM analysis
  WHERE NOT is_surge_event AND date_received >= DATE '2024-08-01'
  GROUP BY 1, 2
)
SELECT product, issue, prior_12m, last_12m, last_12m - prior_12m AS change,
       ROUND(100.0 * (last_12m - prior_12m) / prior_12m, 1) AS growth_pct
FROM w
WHERE prior_12m >= 200
ORDER BY growth_pct DESC
LIMIT 15;

-- 2. Biggest absolute increases
WITH w AS (
  SELECT product, issue,
         COUNT(*) FILTER (WHERE date_received >= DATE '2025-08-01') AS last_12m,
         COUNT(*) FILTER (WHERE date_received >= DATE '2024-08-01'
                            AND date_received <  DATE '2025-08-01') AS prior_12m
  FROM analysis
  WHERE NOT is_surge_event AND date_received >= DATE '2024-08-01'
  GROUP BY 1, 2
)
SELECT product, issue, prior_12m, last_12m, last_12m - prior_12m AS change,
       ROUND(100.0 * (last_12m - prior_12m) / NULLIF(prior_12m, 0), 1) AS growth_pct
FROM w
ORDER BY change DESC
LIMIT 15;
