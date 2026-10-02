SELECT
    YEAR(order_purchase_date) AS sales_year,
    product_category_name_english,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(item_revenue) AS total_revenue
FROM {{ ref('fct_order_items') }}
WHERE order_purchase_date IS NOT NULL
GROUP BY
    YEAR(order_purchase_date),
    product_category_name_english
