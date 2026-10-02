WITH customer_orders AS (
    SELECT
        f.order_id,
        f.customer_id,
        c.customer_unique_id,
        f.order_purchase_date,
        f.item_revenue
    FROM {{ ref('fct_order_items') }} f
    INNER JOIN {{ ref('dim_customer') }} c
        ON f.customer_id = c.customer_id
    WHERE f.order_purchase_date IS NOT NULL
      AND c.customer_unique_id IS NOT NULL
),

customer_first_purchase AS (
    SELECT
        customer_unique_id,
        DATE_TRUNC('MONTH', MIN(order_purchase_date))::DATE
            AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),

customer_activity AS (
    SELECT
        o.customer_unique_id,
        o.order_id,
        o.order_purchase_date,
        o.item_revenue,
        c.cohort_month,
        DATE_TRUNC('MONTH', o.order_purchase_date)::DATE
            AS activity_month
    FROM customer_orders o
    INNER JOIN customer_first_purchase c
        ON o.customer_unique_id = c.customer_unique_id
)

SELECT
    cohort_month,
    activity_month,
    DATEDIFF('MONTH', cohort_month, activity_month)
        AS months_since_first_purchase,
    COUNT(DISTINCT customer_unique_id) AS active_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(item_revenue) AS total_revenue
FROM customer_activity
GROUP BY
    cohort_month,
    activity_month,
    DATEDIFF('MONTH', cohort_month, activity_month)
ORDER BY
    cohort_month,
    activity_month
