SELECT
    LPAD(TO_VARCHAR(GEOLOCATION_ZIP_CODE_PREFIX), 5, '0') AS geolocation_zip_code_prefix,
    TRY_TO_DOUBLE(TO_VARCHAR(GEOLOCATION_LAT)) AS geolocation_lat,
    TRY_TO_DOUBLE(TO_VARCHAR(GEOLOCATION_LNG)) AS geolocation_lng,
    TRIM(GEOLOCATION_CITY) AS geolocation_city,
    UPPER(TRIM(GEOLOCATION_STATE)) AS geolocation_state
FROM {{ source('raw', 'GEOLOCATION') }}
