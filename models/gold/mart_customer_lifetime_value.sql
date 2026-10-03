{{ config(materialized='table') }}

WITH customer_revenue AS (
    SELECT
        dc.customer_unique_id,
        COUNT(DISTINCT foi.order_id) AS total_orders,
        SUM(foi.item_total_amount) AS historical_revenue,
        MIN(foi.order_purchase_date)::DATE AS first_purchase_date,
        MAX(foi.order_purchase_date)::DATE AS last_purchase_date
    FROM {{ ref('fct_order_items') }} AS foi
    JOIN {{ ref('dim_customer') }} AS dc
        ON foi.customer_id = dc.customer_id
    WHERE foi.order_purchase_date IS NOT NULL
    GROUP BY dc.customer_unique_id
)

SELECT
    customer_unique_id,
    total_orders,
    historical_revenue,
    historical_revenue / NULLIF(total_orders, 0)
        AS average_order_value,
    first_purchase_date,
    last_purchase_date,
    DATEDIFF(
        'DAY',
        first_purchase_date,
        last_purchase_date
    ) AS observed_lifespan_days
FROM customer_revenue
