SELECT
    ORDER_ID AS order_id,
    TRY_TO_NUMBER(ORDER_ITEM_ID) AS order_item_id,
    PRODUCT_ID AS product_id,
    SELLER_ID AS seller_id,
    TRY_TO_TIMESTAMP_NTZ(SHIPPING_LIMIT_DATE) AS shipping_limit_date,
    TRY_TO_DECIMAL(TO_VARCHAR(PRICE), 12, 2) AS price,
    TRY_TO_DECIMAL(TO_VARCHAR(FREIGHT_VALUE), 12, 2) AS freight_value
FROM {{ source('raw', 'ORDER_ITEMS') }}
