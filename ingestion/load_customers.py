
import os
from pathlib import Path

import pandas as pd
import snowflake.connector
from dotenv import load_dotenv
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()

# Locate the customer CSV file
csv_path = Path("data/raw/olist_customers_dataset.csv")

if not csv_path.exists():
    raise FileNotFoundError(f"CSV file not found: {csv_path}")

# Read the CSV
df = pd.read_csv(csv_path)

# Standardize column names for Snowflake
df.columns = [
    column.strip().upper()
    for column in df.columns
]

print(f"CSV loaded successfully: {len(df):,} rows")
print("Columns:", list(df.columns))

connection = None

try:
    connection = snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        role=os.getenv("SNOWFLAKE_ROLE"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema="RAW",
    )

    success, nchunks, nrows, _ = write_pandas(
        conn=connection,
        df=df,
        table_name="CUSTOMERS",
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema="RAW",
        auto_create_table=True,
        overwrite=True,
    )

    if not success:
        raise RuntimeError("Snowflake reported that the upload failed.")

    print(f"\nUpload successful: {nrows:,} rows uploaded")
    print(f"Chunks uploaded: {nchunks}")

    cursor = connection.cursor()
    try:
        cursor.execute("""
            SELECT COUNT(*)
            FROM RISHIKA_RETAIL_ANALYTICS_DB.RAW.CUSTOMERS
        """)
        count = cursor.fetchone()[0]
        print(f"Verified Snowflake row count: {count:,}")
    finally:
        cursor.close()

finally:
    if connection is not None:
        connection.close()
