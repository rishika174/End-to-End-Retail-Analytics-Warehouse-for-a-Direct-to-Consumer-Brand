SELECT
    SELLER_ID AS seller_id,
    LPAD(TO_VARCHAR(SELLER_ZIP_CODE_PREFIX), 5, '0') AS seller_zip_code_prefix,
    TRIM(SELLER_CITY) AS seller_city,
    UPPER(TRIM(SELLER_STATE)) AS seller_state
FROM {{ source('raw', 'SELLERS') }}
