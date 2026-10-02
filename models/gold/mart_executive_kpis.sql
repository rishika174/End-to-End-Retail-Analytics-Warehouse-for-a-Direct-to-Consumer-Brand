{{ config(materialized='table') }}

WITH sales AS (
    SELECT
        SUM(total_revenue_including_freight) AS total_revenue,
        SUM(total_orders) AS total_orders
    FROM {{ ref('mart_monthly_sales') }}
),

customers AS (
    SELECT
        COUNT(DISTINCT dc.customer_unique_id) AS unique_customers
    FROM {{ ref('fct_orders') }} o
    JOIN {{ ref('dim_customer') }} dc
        ON o.customer_id = dc.customer_id
)

SELECT
    s.total_revenue,
    s.total_orders,
    c.unique_customers,
    s.total_revenue / NULLIF(s.total_orders, 0) AS average_order_value
FROM sales s
CROSS JOIN customers c
