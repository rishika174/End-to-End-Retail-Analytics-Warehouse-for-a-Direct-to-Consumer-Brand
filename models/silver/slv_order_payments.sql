SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM {{ ref('br_order_payments') }}
WHERE order_id IS NOT NULL
  AND payment_value IS NOT NULL
  AND payment_value >= 0
