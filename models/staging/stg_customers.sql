SELECT
    CUSTOMER_ID AS customer_id,
    CUSTOMER_UNIQUE_ID AS customer_unique_id,
    LPAD(TO_VARCHAR(CUSTOMER_ZIP_CODE_PREFIX), 5, '0')
        AS customer_zip_code_prefix,
    TRIM(CUSTOMER_CITY) AS customer_city,
    UPPER(TRIM(CUSTOMER_STATE)) AS customer_state
FROM {{ source('raw', 'CUSTOMERS') }}
