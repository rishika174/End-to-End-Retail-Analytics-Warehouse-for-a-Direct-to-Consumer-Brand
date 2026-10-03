WITH customer_address_events AS (
    SELECT
        c.customer_id,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        MIN(TO_DATE(o.order_purchase_timestamp)) AS valid_from
    FROM {{ ref('slv_customers') }} AS c
    INNER JOIN {{ ref('slv_orders') }} AS o
        ON c.customer_id = o.customer_id
    WHERE o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        c.customer_id,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state
),

daily_snapshots AS (
    SELECT *
    FROM customer_address_events
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY customer_unique_id, valid_from
        ORDER BY customer_id DESC
    ) = 1
),

previous_address AS (
    SELECT
        *,
        LAG(customer_id) OVER (
            PARTITION BY customer_unique_id
            ORDER BY valid_from, customer_id
        ) AS previous_customer_id,
        LAG(customer_zip_code_prefix) OVER (
            PARTITION BY customer_unique_id
            ORDER BY valid_from, customer_id
        ) AS previous_zip_code,
        LAG(customer_city) OVER (
            PARTITION BY customer_unique_id
            ORDER BY valid_from, customer_id
        ) AS previous_city,
        LAG(customer_state) OVER (
            PARTITION BY customer_unique_id
            ORDER BY valid_from, customer_id
        ) AS previous_state
    FROM daily_snapshots
),

address_changes AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        valid_from
    FROM previous_address
    WHERE previous_customer_id IS NULL
       OR customer_zip_code_prefix IS DISTINCT FROM previous_zip_code
       OR customer_city IS DISTINCT FROM previous_city
       OR customer_state IS DISTINCT FROM previous_state
),

customer_versions AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        valid_from,
        LEAD(valid_from) OVER (
            PARTITION BY customer_unique_id
            ORDER BY valid_from, customer_id
        ) AS valid_to
    FROM address_changes
)

SELECT
    customer_unique_id || '-' ||
        TO_VARCHAR(valid_from, 'YYYYMMDD') AS customer_version_key,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    valid_from,
    valid_to,
    valid_to IS NULL AS is_current
FROM customer_versions
