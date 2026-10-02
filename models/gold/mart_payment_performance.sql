SELECT
    payment_type,
    payment_installments,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(payment_value) AS total_payment_value,
    AVG(payment_value) AS average_payment_value,
    MIN(payment_value) AS minimum_payment_value,
    MAX(payment_value) AS maximum_payment_value
FROM {{ ref('fct_payments') }}
GROUP BY
    payment_type,
    payment_installments
