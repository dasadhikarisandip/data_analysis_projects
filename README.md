# Enterprise Banking Data Pipeline & Fraud Risk Engine

An optimized batch-processing ETL pipeline built with **PySpark** and **Hive**. It simulates a core banking system ingesting transactional ledgers, resolving data skews dynamically, and monitoring rapid geographical velocity threats.

## 🚀 Key Architectural Highlights
* **Mitigated Data Skew:** Built using custom **Key Salting** mechanisms to break down massive account groupings, preventing executor processing lag.
* **Optimized Joins:** Utilizes explicit **Broadcast Joins** for account metadata, completely avoiding costly network shuffles.
* **Window Functions:** Leverages sequential physical lag windows to dynamically compute real-time geographic shifts.

## 🛠️ Tech Stack
* Engine: PySpark (Spark 3.x)
* Storage Layer: Apache Hive Metastore / Parquet Format
