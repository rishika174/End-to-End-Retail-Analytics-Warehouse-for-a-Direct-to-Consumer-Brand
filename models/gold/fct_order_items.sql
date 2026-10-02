SELECT
    order_id,
    order_item_id,
    customer_id,
    product_id,
    product_category_name_english,
    seller_id,
    seller_city,
    seller_state,
    order_purchase_timestamp,
    order_purchase_date,
    order_status,
    price AS item_revenue,
    freight_value,
    item_total_amount,
    delivery_delay_days
FROM {{ ref('slv_order_item_enriched') }}
