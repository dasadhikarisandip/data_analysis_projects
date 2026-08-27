USE DATABASE banking_db;

-- 1. Create a file format for CSV data
CREATE OR REPLACE FILE FORMAT raw.csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null')
  EMPTY_FIELD_AS_NULL = TRUE;

-- 2. Create an internal stage to hold local data files
CREATE OR REPLACE STAGE raw.banking_stage
  FILE_FORMAT = raw.csv_format;

-- 3. [Documentation Note] At this stage, files would be uploaded via SnowSQL PUT command:
-- PUT file://./mock_customers.csv @raw.banking_stage;
-- PUT file://./mock_transactions.csv @raw.banking_stage;

-- 4. Ingest staged data into raw tables
-- (Assuming mock files are placed in paths matching the table names)
COPY INTO raw.customers
FROM @raw.banking_stage/customers/
FILE_FORMAT = (FORMAT_NAME = raw.csv_format)
ON_ERROR = 'CONTINUE';

COPY INTO raw.transactions
FROM @raw.banking_stage/transactions/
FILE_FORMAT = (FORMAT_NAME = raw.csv_format)
ON_ERROR = 'CONTINUE';
