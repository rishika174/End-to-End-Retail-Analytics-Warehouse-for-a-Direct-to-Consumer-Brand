SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM {{ ref('br_geolocation') }}
WHERE geolocation_zip_code_prefix IS NOT NULL
  AND geolocation_lat BETWEEN -90 AND 90
  AND geolocation_lng BETWEEN -180 AND 180
