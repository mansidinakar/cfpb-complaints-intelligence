-- 04_trend.sql
-- Purpose: monthly complaint volume by product with month-over-month change and a 3-month rolling average
-- Surge rows (Jan 15 to 20, 2025) are left out of the change columns so one event does not look like a trend

-- 0. Analysis view: full months only (Aug 2026 is a partial month)
CREATE OR REPLACE VIEW analysis AS
SELECT * FROM complaints_scoped
WHERE date_received < DATE '2026-08-01';

-- 1. Monthly volume by product with MoM change and 3-month rolling average
WITH monthly AS (
  SELECT date_trunc('month', date_received) AS month,
         product,
         COUNT(*) AS complaints,
         COUNT(*) FILTER (WHERE NOT is_surge_event) AS complaints_ex_surge
  FROM analysis
  GROUP BY 1, 2
),
with_lag AS (
  SELECT *,
         LAG(complaints_ex_surge) OVER (PARTITION BY product ORDER BY month) AS prev_month
  FROM monthly
)
SELECT month, product, complaints, complaints_ex_surge,
       complaints_ex_surge - prev_month AS mom_change,
       ROUND(100.0 * (complaints_ex_surge - prev_month) / NULLIF(prev_month, 0), 1) AS mom_pct,
       ROUND(AVG(complaints_ex_surge) OVER (
             PARTITION BY product ORDER BY month
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS rolling_3m
FROM with_lag
ORDER BY product, month;
