SELECT
    PRODUCT_CATEGORY_NAME AS product_category_name,
    TRIM(PRODUCT_CATEGORY_NAME_ENGLISH) AS product_category_name_english
FROM {{ source('raw', 'PRODUCT_CATEGORY_TRANSLATION') }}
