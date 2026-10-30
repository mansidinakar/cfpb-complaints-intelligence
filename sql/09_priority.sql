-- 09_priority.sql
-- Purpose: rank product and issue topics to pick the three a neobank should fix first
-- Score = 0.30 volume + 0.25 growth + 0.25 poor outcome + 0.20 fixability, each scaled 0 to 1
-- Volume, growth and poor outcome use percentile rank across candidates, so one outlier cannot dominate
-- Growth compares Sep 2025 to Jul 2026 with Sep 2023 to Jul 2024, the same 11 calendar months two years apart
-- Neither window touches the Jan 2025 surge or the Block and Zelle complaint campaign, so no flag distorts the baseline
-- Candidates have 1000 or more complaints and 200 or more in the earlier window

-- 1. Metrics per topic
CREATE OR REPLACE TABLE topic_metrics AS
SELECT product, issue,
       COUNT(*) AS complaints,
       COUNT(*) FILTER (WHERE date_received >= DATE '2025-09-01') AS last_11m,
       COUNT(*) FILTER (WHERE date_received < DATE '2024-08-01') AS prior_11m,
       ROUND(100.0 * AVG(got_relief::INT), 1) AS relief_pct,
       ROUND(100.0 * AVG(was_untimely::INT), 1) AS untimely_pct,
       ROUND(100.0 * AVG(poor_outcome::INT), 1) AS poor_outcome_pct
FROM outcomes
GROUP BY product, issue
HAVING COUNT(*) >= 1000
   AND COUNT(*) FILTER (WHERE date_received < DATE '2024-08-01') >= 200;

-- 2. Fixability ratings table
CREATE TABLE IF NOT EXISTS fixability (product VARCHAR, issue VARCHAR, fixability DOUBLE);

-- 3. Score and rank
CREATE OR REPLACE TABLE priority AS
SELECT *, RANK() OVER (ORDER BY score DESC) AS priority_rank
FROM (
  SELECT m.product, m.issue, m.complaints, m.prior_11m, m.last_11m,
         ROUND(100.0 * (m.last_11m - m.prior_11m) / m.prior_11m, 1) AS growth_pct,
         m.relief_pct, m.untimely_pct, m.poor_outcome_pct,
         COALESCE(f.fixability, 0.5) AS fixability,
         ROUND(0.30 * PERCENT_RANK() OVER (ORDER BY m.complaints)
             + 0.25 * PERCENT_RANK() OVER (ORDER BY (m.last_11m - m.prior_11m) * 1.0 / m.prior_11m)
             + 0.25 * PERCENT_RANK() OVER (ORDER BY m.poor_outcome_pct)
             + 0.20 * COALESCE(f.fixability, 0.5), 3) AS score
  FROM topic_metrics m
  LEFT JOIN fixability f ON m.product = f.product AND m.issue = f.issue
);

-- 4. Top 25 candidates
SELECT priority_rank, product, issue, complaints, growth_pct, poor_outcome_pct, fixability, score
FROM priority
ORDER BY priority_rank
LIMIT 25;
