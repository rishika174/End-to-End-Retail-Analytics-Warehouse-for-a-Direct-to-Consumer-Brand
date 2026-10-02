{{ config(materialized='table') }}

WITH customer_orders AS (
    SELECT DISTINCT
        dc.customer_unique_id,
        DATE_TRUNC('MONTH', o.order_purchase_date)::DATE AS activity_month
    FROM {{ ref('fct_orders') }} o
    JOIN {{ ref('dim_customer') }} dc
        ON o.customer_id = dc.customer_id
    WHERE o.order_purchase_date IS NOT NULL
),

customer_cohorts AS (
    SELECT
        customer_unique_id,
        MIN(activity_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),

cohort_activity AS (
    SELECT
        c.cohort_month,
        o.activity_month,
        DATEDIFF(
            MONTH,
            c.cohort_month,
            o.activity_month
        ) AS months_since_first_purchase,
        COUNT(DISTINCT o.customer_unique_id) AS active_customers
    FROM customer_orders o
    JOIN customer_cohorts c
        ON o.customer_unique_id = c.customer_unique_id
    GROUP BY
        c.cohort_month,
        o.activity_month,
        months_since_first_purchase
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)

SELECT
    a.cohort_month,
    a.activity_month,
    a.months_since_first_purchase,
    s.cohort_size,
    a.active_customers,
    a.active_customers / NULLIF(s.cohort_size, 0)::FLOAT
        AS retention_rate
FROM cohort_activity a
JOIN cohort_sizes s
    ON a.cohort_month = s.cohort_month
