
import os
import snowflake.connector
from dotenv import load_dotenv

# Load credentials from the local .env file
load_dotenv()

connection = None

try:
    connection = snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        role=os.getenv("SNOWFLAKE_ROLE"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
    )

    cursor = connection.cursor()
    try:
        cursor.execute("""
            SELECT
                CURRENT_ROLE(),
                CURRENT_DATABASE(),
                CURRENT_SCHEMA(),
                CURRENT_WAREHOUSE()
        """)

        result = cursor.fetchone()

        print("\nSnowflake connection successful!")
        print("Role:", result[0])
        print("Database:", result[1])
        print("Schema:", result[2])
        print("Warehouse:", result[3])

    finally:
        cursor.close()

except Exception as error:
    print("\nSnowflake connection failed.")
    print("Error type:", type(error).__name__)
    print("Error details:", error)

finally:
    if connection is not None:
        connection.close()
