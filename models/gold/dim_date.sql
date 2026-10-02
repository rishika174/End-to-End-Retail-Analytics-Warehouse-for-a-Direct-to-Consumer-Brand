WITH date_bounds AS (
    SELECT
        MIN(order_purchase_date) AS min_date,
        MAX(order_purchase_date) AS max_date
    FROM {{ ref('slv_orders') }}
),
date_spine AS (
    SELECT
        DATEADD(
            'day',
            ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1,
            min_date
        )::DATE AS date_day
    FROM date_bounds,
         TABLE(GENERATOR(ROWCOUNT => 5000))
    WHERE min_date IS NOT NULL
    QUALIFY date_day <= max_date
)
SELECT
    date_day,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    MONTHNAME(date_day) AS month_name,
    TO_CHAR(date_day, 'YYYY-MM') AS year_month,
    DAY(date_day) AS day_of_month,
    DAYOFWEEKISO(date_day) AS day_of_week,
    DAYNAME(date_day) AS day_name,
    CASE
        WHEN DAYOFWEEKISO(date_day) IN (6, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM date_spine
