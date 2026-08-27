USE DATABASE banking_db;
USE WAREHOUSE banking_wh;

-- 1. Create a Data Masking Policy for PII (Requires Accountadmin or specific privileges)
USE ROLE accountadmin;
CREATE OR REPLACE MASKING POLICY analytics.email_mask AS (val string) RETURNS string ->
  CASE
    WHEN current_role() IN ('SYSADMIN', 'ACCOUNTADMIN') THEN val
    ELSE REGEXP_REPLACE(val, '(^[^@]{2})[^@]+(.*)', '\\1****\\2') -- Example: john.doe@bank.com -> jo****@bank.com
  END;

-- Apply masking policy to the raw table or view
ALTER TABLE raw.customers MODIFY COLUMN email SET MASKING POLICY analytics.email_mask;
USE ROLE sysadmin;

-- 2. Create an analytical view combining data
CREATE OR REPLACE VIEW analytics.vw_customer_financial_summary AS
SELECT 
    c.customer_id,
    c.credit_score,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(CASE WHEN t.transaction_type = 'DEPOSIT' THEN t.amount ELSE 0 END) AS total_deposited,
    SUM(CASE WHEN t.transaction_type IN ('WITHDRAWAL', 'MERCHANT_PAYMENT') THEN t.amount ELSE 0 END) AS total_spent,
    (total_deposited - total_spent) AS current_estimated_balance
FROM raw.customers c
LEFT JOIN raw.transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.credit_score;

-- 3. Business Query: Identify High-Value Customers at Risk (Low Credit Score + High Balance)
SELECT 
    customer_id,
    credit_score,
    current_estimated_balance
FROM analytics.vw_customer_financial_summary
WHERE current_estimated_balance > 10000 AND credit_score < 600
ORDER BY current_estimated_balance DESC;

-- 4. Business Query: Monthly Merchant Category Spending Trends
SELECT 
    DATE_TRUNC('MONTH', transaction_date) AS spending_month,
    merchant_category,
    SUM(amount) AS total_category_spend,
    RANK() OVER (PARTITION BY spending_month ORDER BY total_category_spend DESC) AS category_rank
FROM raw.transactions
WHERE transaction_type = 'MERCHANT_PAYMENT'
GROUP BY spending_month, merchant_category;
