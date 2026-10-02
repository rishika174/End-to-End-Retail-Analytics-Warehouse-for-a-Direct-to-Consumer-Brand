SELECT
    ORDER_ID AS order_id,
    CUSTOMER_ID AS customer_id,
    LOWER(TRIM(ORDER_STATUS)) AS order_status,
    TRY_TO_TIMESTAMP_NTZ(ORDER_PURCHASE_TIMESTAMP)
        AS order_purchase_timestamp,
    TRY_TO_TIMESTAMP_NTZ(ORDER_APPROVED_AT)
        AS order_approved_at,
    TRY_TO_TIMESTAMP_NTZ(ORDER_DELIVERED_CARRIER_DATE)
        AS order_delivered_carrier_date,
    TRY_TO_TIMESTAMP_NTZ(ORDER_DELIVERED_CUSTOMER_DATE)
        AS order_delivered_customer_date,
    TRY_TO_TIMESTAMP_NTZ(ORDER_ESTIMATED_DELIVERY_DATE)
        AS order_estimated_delivery_date
FROM {{ source('raw', 'ORDERS') }}
