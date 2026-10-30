-- 07_peer_compare.sql
-- Purpose: which issues are a bigger share of Fintech complaints than Bank complaints
-- Shares are percent of each group's own complaints. Surge rows excluded
-- A topic is a product plus an issue, because issue names repeat across products

-- 1. Issue mix gap, all fintech companies
WITH g AS (
  SELECT cg.company_group, a.product || ' | ' || a.issue AS topic
  FROM analysis a
  JOIN company_groups cg ON a.company = cg.company
  WHERE NOT a.is_surge_event
),
counts AS (
  SELECT company_group, topic, COUNT(*) AS n FROM g GROUP BY 1, 2
),
shares AS (
  SELECT company_group, topic, n,
         100.0 * n / SUM(n) OVER (PARTITION BY company_group) AS pct
  FROM counts
)
SELECT topic,
       ROUND(COALESCE(MAX(pct) FILTER (WHERE company_group = 'Fintech'), 0), 1) AS fintech_pct,
       ROUND(COALESCE(MAX(pct) FILTER (WHERE company_group = 'Bank'), 0), 1) AS bank_pct,
       ROUND(COALESCE(MAX(pct) FILTER (WHERE company_group = 'Fintech'), 0)
           - COALESCE(MAX(pct) FILTER (WHERE company_group = 'Bank'), 0), 1) AS gap_pts
FROM shares
GROUP BY topic
HAVING SUM(n) >= 300
ORDER BY ABS(gap_pts) DESC
LIMIT 15;

-- 2. Same comparison without Block (Block is over half of all fintech complaints)
WITH g AS (
  SELECT cg.company_group, a.product || ' | ' || a.issue AS topic
  FROM analysis a
  JOIN company_groups cg ON a.company = cg.company
  WHERE NOT a.is_surge_event AND a.company <> 'Block, Inc.'
),
counts AS (
  SELECT company_group, topic, COUNT(*) AS n FROM g GROUP BY 1, 2
),
shares AS (
  SELECT company_group, topic, n,
         100.0 * n / SUM(n) OVER (PARTITION BY company_group) AS pct
  FROM counts
)
SELECT topic,
       ROUND(COALESCE(MAX(pct) FILTER (WHERE company_group = 'Fintech'), 0), 1) AS fintech_pct,
       ROUND(COALESCE(MAX(pct) FILTER (WHERE company_group = 'Bank'), 0), 1) AS bank_pct,
       ROUND(COALESCE(MAX(pct) FILTER (WHERE company_group = 'Fintech'), 0)
           - COALESCE(MAX(pct) FILTER (WHERE company_group = 'Bank'), 0), 1) AS gap_pts
FROM shares
GROUP BY topic
HAVING SUM(n) >= 300
ORDER BY ABS(gap_pts) DESC
LIMIT 15;

