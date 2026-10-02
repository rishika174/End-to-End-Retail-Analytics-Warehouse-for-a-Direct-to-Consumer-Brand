SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM {{ ref('br_customers') }}
WHERE customer_id IS NOT NULL
  AND customer_unique_id IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY customer_unique_id
) = 1
