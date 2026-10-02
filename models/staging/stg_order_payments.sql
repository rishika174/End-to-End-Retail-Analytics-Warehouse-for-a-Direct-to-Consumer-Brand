SELECT
    ORDER_ID AS order_id,
    TRY_TO_NUMBER(PAYMENT_SEQUENTIAL) AS payment_sequential,
    LOWER(TRIM(PAYMENT_TYPE)) AS payment_type,
    TRY_TO_NUMBER(PAYMENT_INSTALLMENTS) AS payment_installments,
    TRY_TO_DECIMAL(TO_VARCHAR(PAYMENT_VALUE), 12, 2) AS payment_value
FROM {{ source('raw', 'ORDER_PAYMENTS') }}
