"""
Module Name: main.py
Description: Pipeline orchestrator entrypoint with strict schemas and logging.
"""
import sys
import logging
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, TimestampType
from src.engine import execute_transformation_pipeline

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def init_spark_session():
    return SparkSession.builder \
        .appName("EnterpriseBankingDataPipeline") \
        .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
        .config("spark.sql.shuffle.partitions", "10") \
        .enableHiveSupport() \
        .getOrCreate()

def generate_mock_data(spark):
    tx_schema = StructType([
        StructField("transaction_id", StringType(), False),
        StructField("account_id", StringType(), False),
        StructField("timestamp", TimestampType(), False),
        StructField("transaction_type", StringType(), False),
        StructField("amount", DoubleType(), False),
        StructField("location", StringType(), True)
    ])
    
    data = [
        ("TX1001", "ACC_001", "2026-08-27 09:00:00", "DEPOSIT", 5000.0, "Bangalore"),
        ("TX1002", "ACC_002", "2026-08-27 09:15:00", "DEPOSIT", 12000.0, "Mumbai"),
        ("TX1003", "ACC_001", "2026-08-27 09:17:00", "WITHDRAWAL", 4500.0, "Bangalore"),
        ("TX1004", "ACC_001", "2026-08-27 09:19:00", "WITHDRAWAL", 4800.0, "London"),  # Fraud Hop
        ("TX1005", "ACC_003", "2026-08-27 10:30:00", "DEPOSIT", 1500.0, "Delhi"),
        ("TX1006", "ACC_002", "2026-08-27 11:00:00", "WITHDRAWAL", 15000.0, "Mumbai"),
        ("TX1007", "ACC_001", "2026-08-27 14:00:00", "DEPOSIT", 200.0, "Bangalore")
    ]
    
    dim_data = [
        ("ACC_001", "Gold Premium Tier", "Active"),
        ("ACC_002", "Standard Corporate", "Active"),
        ("ACC_003", "Retail Basic", "Suspended")
    ]
    
    df_tx = spark.createDataFrame(data, schema=tx_schema)
    df_dim = spark.createDataFrame(dim_data, ["account_id", "account_tier", "account_status"])
    return df_tx, df_dim

def main():
    try:
        spark = init_spark_session()
        df_tx, df_dim = generate_mock_data(spark)
        df_balances, df_alerts = execute_transformation_pipeline(df_tx, df_dim)
        
        logger.info("--- Sample Account Balances ---")
        df_balances.show(truncate=False)
        
        logger.info("--- Identified Fraud Alerts ---")
        df_alerts.show(truncate=False)
        
    except Exception as e:
        logger.error(f"Execution failed: {str(e)}")
        sys.exit(1)
    finally:
        spark.stop()

if __name__ == "__main__":
    main()