
import os
from pathlib import Path

import pandas as pd
import snowflake.connector
from dotenv import load_dotenv
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()

DATA_DIR = Path("data/raw")
DATABASE = os.getenv("SNOWFLAKE_DATABASE")
CHUNK_SIZE = 100_000

# Customers is already loaded and verified.
FILES = {
    "GEOLOCATION": "olist_geolocation_dataset.csv",
    "ORDER_ITEMS": "olist_order_items_dataset.csv",
    "ORDER_PAYMENTS": "olist_order_payments_dataset.csv",
    "ORDER_REVIEWS": "olist_order_reviews_dataset.csv",
    "ORDERS": "olist_orders_dataset.csv",
    "PRODUCTS": "olist_products_dataset.csv",
    "SELLERS": "olist_sellers_dataset.csv",
    "PRODUCT_CATEGORY_TRANSLATION": "product_category_name_translation.csv",
}

connection = None

try:
    connection = snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        role=os.getenv("SNOWFLAKE_ROLE"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=DATABASE,
        schema="RAW",
    )

    for table_name, filename in FILES.items():
        csv_path = DATA_DIR / filename

        if not csv_path.exists():
            raise FileNotFoundError(f"CSV file not found: {csv_path}")

        print(f"\nLoading {filename} into RAW.{table_name}...")

        total_rows = 0
        first_chunk = True

        for df in pd.read_csv(
            csv_path,
            chunksize=CHUNK_SIZE,
            low_memory=False,
        ):
            # Normalize column names for Snowflake.
            df.columns = [column.strip().upper() for column in df.columns]

            success, _, rows_uploaded, _ = write_pandas(
                conn=connection,
                df=df,
                table_name=table_name,
                database=DATABASE,
                schema="RAW",
                auto_create_table=True,
                overwrite=first_chunk,
            )

            if not success:
                raise RuntimeError(f"Upload failed for RAW.{table_name}")

            total_rows += rows_uploaded
            first_chunk = False

        # Verify the table count directly in Snowflake.
        cursor = connection.cursor()
        try:
            cursor.execute(
                f'SELECT COUNT(*) FROM "{DATABASE}"."RAW"."{table_name}"'
            )
            verified_count = cursor.fetchone()[0]
        finally:
            cursor.close()

        if total_rows != verified_count:
            raise RuntimeError(
                f"Row count mismatch for {table_name}: "
                f"uploaded={total_rows}, verified={verified_count}"
            )

        print(f"Uploaded rows: {total_rows:,}")
        print(f"Verified rows: {verified_count:,}")

    print("\nAll remaining datasets loaded and verified successfully!")

finally:
    if connection is not None:
        connection.close()
