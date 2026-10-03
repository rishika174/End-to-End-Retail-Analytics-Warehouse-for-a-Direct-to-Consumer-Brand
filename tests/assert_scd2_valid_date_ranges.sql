SELECT
    customer_version_key,
    valid_from,
    valid_to
FROM {{ ref('dim_customer_scd2') }}
WHERE valid_to IS NOT NULL
  AND valid_to <= valid_from
