-- 10_fixability.sql
-- Purpose: analyst ratings from 0 to 1 of how much a neobank's own product, policy and operations can change each issue
-- 0.8 mostly in the company's control, 0.5 to 0.7 mixed, 0.3 to 0.4 pricing or vague buckets
-- These are judgments, not data, and the memo will say so

DELETE FROM fixability;

INSERT INTO fixability VALUES
 ('Checking or savings account', 'Managing an account', 0.7),
 ('Checking or savings account', 'Problem with a lender or other company charging your account', 0.7),
 ('Checking or savings account', 'Closing an account', 0.8),
 ('Checking or savings account', 'Opening an account', 0.7),
 ('Checking or savings account', 'Problem caused by your funds being low', 0.5),
 ('Money transfer, virtual currency, or money service', 'Fraud or scam', 0.5),
 ('Money transfer, virtual currency, or money service', 'Unauthorized transactions or other transaction problem', 0.6),
 ('Money transfer, virtual currency, or money service', 'Managing, opening, or closing your mobile wallet account', 0.8),
 ('Money transfer, virtual currency, or money service', 'Trouble accessing funds in your mobile or digital wallet', 0.8),
 ('Money transfer, virtual currency, or money service', 'Other transaction problem', 0.4),
 ('Money transfer, virtual currency, or money service', 'Money was not available when promised', 0.6),
 ('Money transfer, virtual currency, or money service', 'Problem with customer service', 0.8),
 ('Money transfer, virtual currency, or money service', 'Other service problem', 0.3),
 ('Money transfer, virtual currency, or money service', 'Confusing or missing disclosures', 0.8),
 ('Money transfer, virtual currency, or money service', 'Unexpected or other fees', 0.4),
 ('Credit card', 'Problem with a purchase shown on your statement', 0.5),
 ('Credit card', 'Trouble using your card', 0.6),
 ('Credit card', 'Other features, terms, or problems', 0.3),
 ('Credit card', 'Advertising and marketing, including promotional offers', 0.7),
 ('Credit card', 'Closing your account', 0.7),
 ('Credit card', 'Fees or interest', 0.3),
 ('Credit card', 'Getting a credit card', 0.5),
 ('Credit card', 'Struggling to pay your bill', 0.5),
 ('Credit card', 'Problem when making payments', 0.6),
 ('Prepaid card', 'Problem with a purchase or transfer', 0.5),
 ('Prepaid card', 'Trouble using the card', 0.6),
 ('Prepaid card', 'Problem getting a card or closing an account', 0.7),
 ('Prepaid card', 'Unexpected or other fees', 0.4);
