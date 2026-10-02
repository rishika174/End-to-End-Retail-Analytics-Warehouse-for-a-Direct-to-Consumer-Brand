SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_purchase_date,
    oi.product_id,
    p.product_category_name,
    p.product_category_name_english,
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,
    oi.item_total_amount,
    o.delivery_delay_days
FROM {{ ref('slv_order_items') }} oi
LEFT JOIN {{ ref('slv_orders') }} o
    ON oi.order_id = o.order_id
LEFT JOIN {{ ref('slv_products') }} p
    ON oi.product_id = p.product_id
LEFT JOIN {{ ref('slv_sellers') }} s
    ON oi.seller_id = s.seller_id
