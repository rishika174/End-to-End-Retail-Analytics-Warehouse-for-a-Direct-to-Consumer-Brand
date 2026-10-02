SELECT
    PRODUCT_ID AS product_id,
    PRODUCT_CATEGORY_NAME AS product_category_name,
    TRY_TO_NUMBER(TO_VARCHAR(PRODUCT_NAME_LENGHT)) AS product_name_length,
    TRY_TO_NUMBER(TO_VARCHAR(PRODUCT_DESCRIPTION_LENGHT)) AS product_description_length,
    TRY_TO_NUMBER(TO_VARCHAR(PRODUCT_PHOTOS_QTY)) AS product_photos_qty,
    TRY_TO_NUMBER(TO_VARCHAR(PRODUCT_WEIGHT_G)) AS product_weight_g,
    TRY_TO_DECIMAL(TO_VARCHAR(PRODUCT_LENGTH_CM), 10, 2) AS product_length_cm,
    TRY_TO_DECIMAL(TO_VARCHAR(PRODUCT_HEIGHT_CM), 10, 2) AS product_height_cm,
    TRY_TO_DECIMAL(TO_VARCHAR(PRODUCT_WIDTH_CM), 10, 2) AS product_width_cm
FROM {{ source('raw', 'PRODUCTS') }}
