SELECT
    p.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category_name_english,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM {{ ref('br_products') }} p
LEFT JOIN {{ ref('br_product_category_translation') }} t
    ON p.product_category_name = t.product_category_name
WHERE p.product_id IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY p.product_id
    ORDER BY p.product_category_name
) = 1
