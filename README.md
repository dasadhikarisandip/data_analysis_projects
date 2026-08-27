------------------------------------------------------------------------------------------------------------------------------------------
### Enterprise Banking Data Pipeline & Fraud Risk Engine(Pyspark & Hive)
An optimized batch-processing ETL pipeline built with PySpark and Hive. 
It simulates a core banking system ingesting transactional ledgers, 
resolving data skews dynamically and monitoring rapid geographical velocity threats.

###🚀 Key Architectural Highlights
Mitigated Data Skew: Built using custom Key Salting mechanisms to break down massive account groupings, 
preventing executor processing lag.
Optimized Joins: Utilizes explicit Broadcast Joins for account metadata, 
completely avoiding costly network shuffles.
Window Functions: Leverages sequential physical lag windows to dynamically compute real-time geographic shifts.

### 🛠️ Tech Stack
Engine: PySpark (Spark 3.x)
Storage Layer: Apache Hive Metastore / Parquet Format
------------------------------------------------------------------------------------------------------------------------------------------

### SnowSQL Banking Data Analysis Pipeline(Snowflake - Snowsql)
An automated data engineering and analytics pipeline built natively in Snowflake using SnowSQL. This project simulates a retail banking environment by ingesting customer profiles and financial transactions, securing sensitive data via dynamic data masking, calculating financial risk metrics, and orchestrating nightly workflows. 

### 🎯 Project Features
**Infrastructure as Code (IaC):** Complete schema separation (RAW vs ANALYTICS) and compute lifecycle management.
**Secure PII Masking:** Dynamic masking policies applied to customer emails based on access roles.
**Financial Analytics:** Advanced window functions and aggregations tracking monthly category spending and high-value customer balances.
**Native Orchestration:** Cron-based Snowflake DAG (Directed Acyclic Graph) tasks scheduling automated data ingestion.
------------------------------------------------------------------------------------------------------------------------------------------
