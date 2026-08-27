-- 1. Create a dedicated virtual warehouse
CREATE OR REPLACE WAREHOUSE banking_wh 
WITH WAREHOUSE_SIZE = 'XSMALL' 
AUTO_SUSPEND = 300 
AUTO_RESUME = TRUE 
COMMENT = 'Warehouse for banking analytics project';

USE WAREHOUSE banking_wh;

-- 2. Create database and schemas
CREATE OR REPLACE DATABASE banking_db;
USE DATABASE banking_db;

CREATE OR REPLACE SCHEMA raw;
CREATE OR REPLACE SCHEMA analytics;

-- 3. Create raw staging tables
CREATE OR REPLACE TABLE raw.customers (
    customer_id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    signup_date DATE,
    credit_score INT
);

CREATE OR REPLACE TABLE raw.transactions (
    transaction_id STRING,
    customer_id INT,
    transaction_date TIMESTAMP,
    amount NUMBER(12,2),
    transaction_type STRING, -- 'DEPOSIT', 'WITHDRAWAL', 'MERCHANT_PAYMENT'
    merchant_category STRING
);