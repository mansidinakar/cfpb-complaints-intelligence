-- Lookup table: peer companies labeled Fintech or Bank
CREATE OR REPLACE TABLE company_groups AS
SELECT * FROM (VALUES
  ('Block, Inc.', 'Fintech'),
  ('Paypal Holdings, Inc', 'Fintech'),
  ('Chime Financial Inc', 'Fintech'),
  ('Chime Inc.', 'Fintech'),
  ('SOFI TECHNOLOGIES, INC.', 'Fintech'),
  ('ROBINHOOD MARKETS INC.', 'Fintech'),
  ('Coinbase, Inc.', 'Fintech'),
  ('TransferWise Ltd', 'Fintech'),
  ('Remitly, Inc.', 'Fintech'),
  ('MoneyLion Inc.', 'Fintech'),
  ('Dave Operating, LLC', 'Fintech'),
  ('JPMORGAN CHASE & CO.', 'Bank'),
  ('BANK OF AMERICA, NATIONAL ASSOCIATION', 'Bank'),
  ('WELLS FARGO & COMPANY', 'Bank'),
  ('CAPITAL ONE FINANCIAL CORPORATION', 'Bank'),
  ('CITIBANK, N.A.', 'Bank')
) AS t(company, company_group);

-- Check: complaints per group
SELECT g.company_group, COUNT(*) AS complaints
FROM complaints c JOIN company_groups g USING (company)
GROUP BY 1;
