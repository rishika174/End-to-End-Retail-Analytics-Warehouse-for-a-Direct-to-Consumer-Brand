SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    TO_DATE(order_purchase_timestamp) AS order_purchase_date,
    CASE
        WHEN order_delivered_customer_date IS NOT NULL
         AND order_estimated_delivery_date IS NOT NULL
        THEN DATEDIFF(
            'day',
            order_estimated_delivery_date,
            order_delivered_customer_date
        )
        ELSE NULL
    END AS delivery_delay_days
FROM {{ ref('br_orders') }}
WHERE order_id IS NOT NULL
  AND customer_id IS NOT NULL
