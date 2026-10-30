-- 01_profile.sql: data profiling for the CFPB complaints project
-- Table: complaints (605,225 rows, Sept 1 2023 to Aug 14 2026, 4 products)

-- 1. Size and date range
SELECT COUNT(*) AS rows, MIN(date_received) AS first_date, MAX(date_received) AS last_date
FROM complaints;

-- 2. Duplicate IDs (should be 0)
SELECT COUNT(*) - COUNT(DISTINCT complaint_id) AS duplicate_ids FROM complaints;

-- 4. Products in scope
SELECT product, COUNT(*) AS complaints FROM complaints GROUP BY 1 ORDER BY 2 DESC;

-- 5. Top 20 companies
SELECT company, COUNT(*) AS complaints FROM complaints GROUP BY 1 ORDER BY 2 DESC LIMIT 20;

-- 6. Peer company check
SELECT company, COUNT(*) AS complaints FROM complaints
WHERE company ILIKE '%chime%' OR company ILIKE '%block%' OR company ILIKE '%paypal%'
   OR company ILIKE '%sofi%' OR company ILIKE '%varo%' OR company ILIKE '%dave%'
   OR company ILIKE '%moneylion%' OR company ILIKE '%robinhood%' OR company ILIKE '%coinbase%'
   OR company ILIKE '%wise%' OR company ILIKE '%remitly%'
GROUP BY 1 ORDER BY 2 DESC;

-- 7. Monthly volume
SELECT date_trunc('month', date_received) AS month, COUNT(*) AS complaints
FROM complaints GROUP BY 1 ORDER BY 1;

-- 8. Who drove the January 2025 spike? 
SELECT company,
       COUNT(*) FILTER (WHERE date_received BETWEEN DATE '2024-12-01' AND DATE '2024-12-31') AS dec_2024,
       COUNT(*) FILTER (WHERE date_received BETWEEN DATE '2025-01-01' AND DATE '2025-01-31') AS jan_2025,
       COUNT(*) FILTER (WHERE date_received BETWEEN DATE '2025-02-01' AND DATE '2025-02-28') AS feb_2025
FROM complaints
WHERE date_received BETWEEN DATE '2024-12-01' AND DATE '2025-02-28'
GROUP BY 1 ORDER BY jan_2025 - dec_2024 DESC LIMIT 10;

-- 9a. Busiest days in Jan 2025 
SELECT date_received, COUNT(*) AS complaints FROM complaints
WHERE date_received BETWEEN DATE '2025-01-01' AND DATE '2025-01-31'
GROUP BY 1 ORDER BY 2 DESC LIMIT 5;

-- 9b. Issues in Jan 2025
SELECT product, issue, COUNT(*) AS complaints FROM complaints
WHERE date_received BETWEEN DATE '2025-01-01' AND DATE '2025-01-31'
GROUP BY 1, 2 ORDER BY 3 DESC LIMIT 10;

-- 10. Credit bureaus by product
SELECT company, product, COUNT(*) AS complaints FROM complaints
WHERE company IN ('EQUIFAX, INC.', 'TRANSUNION INTERMEDIATE HOLDINGS, INC.', 'Experian Information Solutions Inc.')
GROUP BY 1, 2 ORDER BY 1, 3 DESC;

-- 11. Who drove the spikes
SELECT company, issue, COUNT(*) AS complaints
FROM complaints
WHERE date_received BETWEEN DATE '2025-01-15' AND DATE '2025-01-20'
GROUP BY 1, 2 ORDER BY 3 DESC LIMIT 10

--12. Credit reporting style issues
SELECT issue, COUNT(*) AS complaints
FROM complaints
WHERE issue ILIKE '%report%' OR issue ILIKE '%credit score%'
   OR issue ILIKE '%investigation%' OR issue ILIKE '%fraud alert%'
   OR issue ILIKE '%identity theft%' OR issue ILIKE '%monitoring%'
GROUP BY 1 ORDER BY 2 DESC
