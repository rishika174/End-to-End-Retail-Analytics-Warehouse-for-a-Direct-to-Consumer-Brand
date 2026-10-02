import os

import snowflake.connector
from dotenv import load_dotenv

load_dotenv()

connection = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["SNOWFLAKE_USER"],
    password=os.environ["SNOWFLAKE_PASSWORD"],
    role=os.environ["SNOWFLAKE_ROLE"],
    warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
    database=os.environ["SNOWFLAKE_DATABASE"],
    schema="GOLD",
)

queries = [
    ("FCT_ORDER_ITEMS", "SELECT COUNT(*) FROM GOLD.FCT_ORDER_ITEMS"),
    ("FCT_ORDERS", "SELECT COUNT(*) FROM GOLD.FCT_ORDERS"),
    ("DIM_CUSTOMER", "SELECT COUNT(*) FROM GOLD.DIM_CUSTOMER"),
    ("DIM_PRODUCT", "SELECT COUNT(*) FROM GOLD.DIM_PRODUCT"),
    ("FCT_MARKETING_SPEND", "SELECT COUNT(*) FROM GOLD.FCT_MARKETING_SPEND"),
    (
        "MART_MARKETING_PERFORMANCE",
        "SELECT COUNT(*) FROM GOLD.MART_MARKETING_PERFORMANCE",
    ),
]

try:
    cursor = connection.cursor()
    try:
        for table_name, query in queries:
            cursor.execute(query)
            count = cursor.fetchone()[0]
            print(f"{table_name}: {count:,} rows")

        cursor.execute("""
            SELECT
                report_month,
                marketing_channel,
                synthetic_ad_spend,
                total_sales_revenue,
                illustrative_sales_to_spend_ratio,
                metric_limitation
            FROM GOLD.MART_MARKETING_PERFORMANCE
            ORDER BY report_month, marketing_channel
            LIMIT 10
        """)

        print("\nMarketing mart sample:")
        for row in cursor.fetchall():
            print(row)
    finally:
        cursor.close()
finally:
    connection.close()
