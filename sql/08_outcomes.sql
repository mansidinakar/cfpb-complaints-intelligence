-- 08_outcomes.sql
-- Purpose: how complaints end, by product, issue and company group
-- Resolved means the response is not In progress. Relief means monetary or non-monetary relief
-- Poor outcome means no relief or an untimely response. Surge rows are excluded

-- 0. Resolved complaints with outcome flags
CREATE OR REPLACE VIEW outcomes AS
SELECT *,
  (company_response IN ('Closed with monetary relief', 'Closed with non-monetary relief')) AS got_relief,
  (company_response = 'Untimely response' OR timely_response = 'No') AS was_untimely,
  (NOT (company_response IN ('Closed with monetary relief', 'Closed with non-monetary relief'))
   OR company_response = 'Untimely response' OR timely_response = 'No') AS poor_outcome
FROM analysis
WHERE NOT is_surge_event AND company_response <> 'In progress';

-- 1. Outcomes by product
SELECT product, COUNT(*) AS complaints,
       ROUND(100.0 * AVG(got_relief::INT), 1) AS relief_pct,
       ROUND(100.0 * AVG(was_untimely::INT), 1) AS untimely_pct,
       ROUND(100.0 * AVG(poor_outcome::INT), 1) AS poor_outcome_pct
FROM outcomes
GROUP BY product
ORDER BY complaints DESC;

-- 2. Worst five issues per product by poor outcome rate (issues with 500 or more complaints)
SELECT * FROM (
  SELECT product, issue, COUNT(*) AS complaints,
         ROUND(100.0 * AVG(got_relief::INT), 1) AS relief_pct,
         ROUND(100.0 * AVG(was_untimely::INT), 1) AS untimely_pct,
         ROUND(100.0 * AVG(poor_outcome::INT), 1) AS poor_outcome_pct,
         RANK() OVER (PARTITION BY product ORDER BY AVG(poor_outcome::INT) DESC) AS poor_rank
  FROM outcomes
  GROUP BY product, issue
  HAVING COUNT(*) >= 500
)
WHERE poor_rank <= 5
ORDER BY product, poor_rank;

-- 3. Fintech vs Bank
SELECT cg.company_group, COUNT(*) AS complaints,
       ROUND(100.0 * AVG(o.got_relief::INT), 1) AS relief_pct,
       ROUND(100.0 * AVG(o.was_untimely::INT), 1) AS untimely_pct,
       ROUND(100.0 * AVG(o.poor_outcome::INT), 1) AS poor_outcome_pct
FROM outcomes o
JOIN company_groups cg ON o.company = cg.company
GROUP BY cg.company_group;

-- 4. Each peer company with 1000 or more complaints
SELECT cg.company_group, o.company, COUNT(*) AS complaints,
       ROUND(100.0 * AVG(o.got_relief::INT), 1) AS relief_pct,
       ROUND(100.0 * AVG(o.was_untimely::INT), 1) AS untimely_pct,
       ROUND(100.0 * AVG(o.poor_outcome::INT), 1) AS poor_outcome_pct
FROM outcomes o
JOIN company_groups cg ON o.company = cg.company
GROUP BY cg.company_group, o.company
HAVING COUNT(*) >= 1000
ORDER BY cg.company_group, poor_outcome_pct DESC;
