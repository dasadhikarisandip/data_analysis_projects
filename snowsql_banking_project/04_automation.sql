USE DATABASE banking_db;
USE SCHEMA analytics;
USE ROLE sysadmin;

-- 1. Create a Stored Procedure to encapsulate the loading process
CREATE OR REPLACE PROCEDURE analytics.sp_load_banking_data()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Ingest fresh customer data
    COPY INTO raw.customers
    FROM @raw.banking_stage/customers/
    FILE_FORMAT = (FORMAT_NAME = raw.csv_format)
    ON_ERROR = 'CONTINUE';

    -- Ingest fresh transaction data
    COPY INTO raw.transactions
    FROM @raw.banking_stage/transactions/
    FILE_FORMAT = (FORMAT_NAME = raw.csv_format)
    ON_ERROR = 'CONTINUE';

    RETURN 'Ingestion completed successfully.';
END;
$$;

-- 2. Create a Root Task to trigger ingestion nightly at 1 AM UTC
CREATE OR REPLACE TASK analytics.tsk_nightly_ingestion
  WAREHOUSE = banking_wh
  SCHEDULE = 'USING CRON 0 1 * * * UTC' -- Run at 01:00 AM every day
AS 
  CALL analytics.sp_load_banking_data();

-- 3. Create a Dependent Task to refresh/verify the summary views
CREATE OR REPLACE TASK analytics.tsk_nightly_reporting
  WAREHOUSE = banking_wh
  AFTER analytics.tsk_nightly_ingestion
AS
  -- This forces a metadata or query cache refresh if materialised tables are added later
  SELECT COUNT(*) FROM analytics.vw_customer_financial_summary;

-- 4. Resume the tasks (Tasks are created in a PAUSED state by default)
ALTER TASK analytics.tsk_nightly_ingestion RESUME;
ALTER TASK analytics.tsk_nightly_reporting RESUME;
