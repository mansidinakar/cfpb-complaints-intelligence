-- 11_sensitivity.sql
-- Purpose: test whether the top-ranked topics hold up when the weights and the company set change
-- Company sets: all companies (priority_all) and without Block and Early Warning Services (priority_xb)
-- Six weight sets x two company sets = 12 scenarios
-- Weights are volume, growth, poor outcome, fixability

CREATE OR REPLACE TABLE weight_sets AS
SELECT * FROM (VALUES
  ('base',          0.30, 0.25, 0.25, 0.20),
  ('equal',         0.25, 0.25, 0.25, 0.25),
  ('no_fixability', 0.40, 0.30, 0.30, 0.00),
  ('volume_heavy',  0.50, 0.20, 0.20, 0.10),
  ('growth_heavy',  0.20, 0.45, 0.20, 0.15),
  ('outcome_heavy', 0.20, 0.20, 0.45, 0.15)
) AS t(weight_set, w_vol, w_growth, w_out, w_fix);

CREATE OR REPLACE TABLE scenario_ranks AS
WITH pooled AS (
  SELECT 'all' AS company_set, * FROM priority_all
  UNION ALL
  SELECT 'ex_block_zelle' AS company_set, * FROM priority_xb
),
pr AS (
  SELECT company_set, product, issue, fixability,
         PERCENT_RANK() OVER (PARTITION BY company_set ORDER BY complaints) AS p_vol,
         PERCENT_RANK() OVER (PARTITION BY company_set ORDER BY growth_pct) AS p_growth,
         PERCENT_RANK() OVER (PARTITION BY company_set ORDER BY poor_outcome_pct) AS p_out
  FROM pooled
),
scored AS (
  SELECT pr.company_set, w.weight_set, pr.product, pr.issue,
         w.w_vol * p_vol + w.w_growth * p_growth + w.w_out * p_out + w.w_fix * fixability AS score
  FROM pr CROSS JOIN weight_sets w
)
SELECT *, RANK() OVER (PARTITION BY company_set, weight_set ORDER BY score DESC) AS rnk
FROM scored;
