SELECT
    product_id,
    product_category_name_english,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(item_revenue) AS total_revenue,
    SUM(freight_value) AS total_freight,
    SUM(item_total_amount) AS total_item_value,
    AVG(item_revenue) AS average_item_revenue
FROM {{ ref('fct_order_items') }}
GROUP BY
    product_id,
    product_category_name_english
