"""
Module Name: engine.py
Description: Advanced business transformations, salting, and analytical windows.
"""
from pyspark.sql import functions as F
from pyspark.sql.window import Window

def execute_transformation_pipeline(df_tx, df_dim):
    # 1. Broadcast Join Optimization for low-cardinality dimension mapping
    df_enriched = df_tx.join(F.broadcast(df_dim), on="account_id", how="inner")
    
    # 2. Financial Ledger Calculations with Salting to handle hot keys (Data Skew)
    df_salted = df_enriched.withColumn("salt", F.concat(F.col("account_id"), F.lit("_"), (F.rand(42) * 10 % 2).cast("int")))
    
    df_normalized = df_salted.withColumn(
        "net_amount",
        F.when(F.col("transaction_type") == "WITHDRAWAL", -F.col("amount")).otherwise(F.col("amount"))
    )
    
    # 2-Step Aggregation pattern to resolve data skews evenly across executors
    df_intermediate_bal = df_normalized.groupBy("account_id", "salt", "account_tier").agg(
        F.sum("net_amount").alias("subtotal_amount"),
        F.count("transaction_id").alias("subtotal_count")
    )
    
    df_final_balances = df_intermediate_bal.groupBy("account_id", "account_tier").agg(
        F.sum("subtotal_amount").alias("current_balance"),
        F.sum("subtotal_count").alias("total_daily_transactions")
    ).withColumn(
        "is_overdrawn", F.when(F.col("current_balance") < 0, True).otherwise(False)
    )
    
    # 3. Security Risk Engine: Location Fraud Check utilizing Window functions
    account_window = Window.partitionBy("account_id").orderBy("timestamp")
    
    df_risk_analysis = df_enriched \
        .withColumn("prev_timestamp", F.lag("timestamp", 1).over(account_window)) \
        .withColumn("prev_location", F.lag("location", 1).over(account_window))
    
    df_risk_analysis = df_risk_analysis.withColumn(
        "seconds_since_last_tx",
        F.col("timestamp").cast("long") - F.col("prev_timestamp").cast("long")
    )
    
    # Criteria: Account activity detected in two different cities in under 10 minutes (600s)
    df_alerts = df_risk_analysis.filter(
        (F.col("seconds_since_last_tx") <= 600) & 
        (F.col("location") != F.col("prev_location"))
    ).select(
        "transaction_id", "account_id", "account_tier", "timestamp", 
        "location", "prev_location", "seconds_since_last_tx", "amount"
    )
    
    return df_final_balances, df_alerts
