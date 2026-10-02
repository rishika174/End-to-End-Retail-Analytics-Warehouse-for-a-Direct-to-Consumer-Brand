SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM {{ ref('br_sellers') }}
WHERE seller_id IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY seller_id
    ORDER BY seller_city
) = 1
