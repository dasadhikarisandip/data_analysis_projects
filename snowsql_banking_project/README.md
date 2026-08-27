### SnowSQL Banking Data Analysis Pipeline

An automated data engineering and analytics pipeline built natively in Snowflake using SnowSQL. This project simulates a retail banking environment by ingesting customer profiles and financial transactions, securing sensitive data via dynamic data masking, calculating financial risk metrics, and orchestrating nightly workflows. 

### 🎯 Project Features

* **Infrastructure as Code (IaC):** Complete schema separation (RAW vs ANALYTICS) and compute lifecycle management.
* **Secure PII Masking:** Dynamic masking policies applied to customer emails based on access roles.
* **Financial Analytics:** Advanced window functions and aggregations tracking monthly category spending and high-value customer balances.
* **Native Orchestration:** Cron-based Snowflake DAG (Directed Acyclic Graph) tasks scheduling automated data ingestion.

### 📂 Project Structure

text

snowsql_banking_project/
├── config.ini            # SnowSQL credentials and session parameters
├── 01_setup.sql          # Virtual warehouse, database, and schema setup
├── 02_ingestion.sql      # Storage stages, file formats, and COPY commands
├── 03_analysis.sql       # PII masking policies, business views, and queries
├── 04_automation.sql     # Stored procedures and cron tasks orchestration
├── customers.csv         # Mock customer dataset (PII included)
├── transactions.csv      # Mock ledger transaction dataset
└── README.md             # Project documentation

Use code with caution.

### 🛠️ Prerequisites

1. **SnowSQL CLI:** Ensure you have the Snowflake command-line client installed. [Download guide here](https://docs.snowflake.com/en/user-guide/snowsql-install-config).
2. **Privileged Account Access:** Administrative privileges (SYSADMIN and ACCOUNTADMIN) to create compute engines and system policies.

### 🚀 Deployment Instructions

### 1. Configure Connection

Open config.ini and update the properties with your target Snowflake account identifier and credentials: 

ini

[connections.banking_dev]
accountname = your_account_locator
username = your_username
password = your_password
role = sysadmin
warehouse = banking_wh
dbname = banking_db
schemaname = public

Use code with caution.

### 2. Run the Pipeline Execution Scripts

Open your terminal inside the project root directory and execute the following SnowSQL commands sequentially: 

bash

# Step 1: Provision infrastructure and base tables
snowsql -c banking_dev -f 01_setup.sql

# Step 2: Upload local mock CSVs to Snowflake internal stages
snowsql -c banking_dev -q "PUT file://./customers.csv @banking_db.raw.banking_stage/customers/;"
snowsql -c banking_dev -q "PUT file://./transactions.csv @banking_db.raw.banking_stage/transactions/;"

# Step 3: Parse and execute bulk data copy operation
snowsql -c banking_dev -f 02_ingestion.sql

# Step 4: Apply secure data masking and calculate analytical models
snowsql -c banking_dev -f 03_analysis.sql

# Step 5: Activate the automated nightly processing pipelines
snowsql -c banking_dev -f 04_automation.sql

Use code with caution.

### 📋 Core Analytical Views & Business Value

### analytics.vw_customer_financial_summary

Combines relational customer properties with transaction ledgers to yield structural indicators: 

* Total cash flow volume (Deposits vs. Spend)
* Current calculated balance estimation
* Flagging profiles exhibiting high liquid balances alongside sub-optimal credit scores (< 600) to isolate credit and default risks.

### Automated Task Pipeline (tsk_nightly_ingestion)

Triggers an encapsulated Snowflake scripting stored procedure at **01:00 AM UTC daily**. This process pulls delta data dropped into the cloud stage and routes updates straight through to downstream reporting layers automatically.