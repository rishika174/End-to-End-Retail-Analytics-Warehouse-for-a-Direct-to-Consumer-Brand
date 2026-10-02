{{ config(materialized='table') }}

WITH customer_purchase_summary AS (
    SELECT
        dc.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        MIN(o.order_purchase_date)::DATE AS first_purchase_date,
        MAX(o.order_purchase_date)::DATE AS last_purchase_date
    FROM {{ ref('fct_orders') }} o
    JOIN {{ ref('dim_customer') }} dc
        ON o.customer_id = dc.customer_id
    WHERE o.order_purchase_date IS NOT NULL
    GROUP BY dc.customer_unique_id
)

SELECT
    customer_unique_id,
    total_orders,
    first_purchase_date,
    last_purchase_date,
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type
FROM customer_purchase_summary
