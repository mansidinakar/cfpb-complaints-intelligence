-- 05_top_issues.sql
-- Purpose: which issues dominate each product (surge rows excluded)

-- 1. Top 10 issues per product, ranked by volume
SELECT * FROM (
  SELECT product, issue, COUNT(*) AS complaints,
         ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY product), 1) AS pct_of_product,
         RANK() OVER (PARTITION BY product ORDER BY COUNT(*) DESC) AS rnk
  FROM analysis
  WHERE NOT is_surge_event
  GROUP BY product, issue
)
WHERE rnk <= 10
ORDER BY product, rnk;

-- 2. Running share: how quickly the top issues add up to the whole product
WITH issue_counts AS (
  SELECT product, issue, COUNT(*) AS complaints
  FROM analysis
  WHERE NOT is_surge_event
  GROUP BY 1, 2
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY product ORDER BY complaints DESC, issue) AS issue_rank,
         100.0 * SUM(complaints) OVER (
             PARTITION BY product ORDER BY complaints DESC, issue
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
           / SUM(complaints) OVER (PARTITION BY product) AS cum_pct
  FROM issue_counts
)
SELECT product, issue_rank, issue, complaints, ROUND(cum_pct, 1) AS cum_pct
FROM ranked
WHERE issue_rank <= 8
ORDER BY product, issue_rank;
