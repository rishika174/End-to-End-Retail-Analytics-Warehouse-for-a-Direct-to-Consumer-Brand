import os
from pathlib import Path

import pandas as pd
import snowflake.connector
from dotenv import load_dotenv
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()

csv_path = Path("data/raw/marketing_spend.csv")

if not csv_path.exists():
    raise FileNotFoundError(
        f"{csv_path} not found. Run ingestion/generate_marketing_spend.py first."
    )

df = pd.read_csv(csv_path)
connection = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["SNOWFLAKE_USER"],
    password=os.environ["SNOWFLAKE_PASSWORD"],
    role=os.environ["SNOWFLAKE_ROLE"],
    warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
    database=os.environ["SNOWFLAKE_DATABASE"],
    schema="RAW",
)

try:
    cursor = connection.cursor()
    try:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS RAW.MARKETING_SPEND (
                SPEND_DATE DATE,
                MARKETING_CHANNEL VARCHAR(100),
                CAMPAIGN_NAME VARCHAR(200),
                AD_SPEND NUMBER(12, 2),
                IMPRESSIONS NUMBER(12, 0),
                CLICKS NUMBER(12, 0),
                DATA_SOURCE VARCHAR(100)
            )
        """)
        cursor.execute("TRUNCATE TABLE RAW.MARKETING_SPEND")
    finally:
        cursor.close()

    success, nchunks, nrows, _ = write_pandas(
        connection,
        df,
        table_name="MARKETING_SPEND",
        database=os.environ["SNOWFLAKE_DATABASE"],
        schema="RAW",
        auto_create_table=False,
        overwrite=False,
        quote_identifiers=False,
    )

    if not success or nrows != len(df):
        raise RuntimeError(
            f"Load failed: success={success}, loaded={nrows}, "
            f"expected={len(df)}"
        )

    print(f"Successfully loaded {nrows} rows into RAW.MARKETING_SPEND.")

finally:
    connection.close()
