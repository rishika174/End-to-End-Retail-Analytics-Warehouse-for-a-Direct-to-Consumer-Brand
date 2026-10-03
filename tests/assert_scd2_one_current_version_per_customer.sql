SELECT
    customer_unique_id
FROM {{ ref('dim_customer_scd2') }}
GROUP BY customer_unique_id
HAVING SUM(IFF(is_current, 1, 0)) != 1
