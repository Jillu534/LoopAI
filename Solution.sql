WITH UberEatsData AS (
  SELECT
    slug AS ubereats_slug,
    JSON_VALUE(response, '$.data.menus."26bd579e-5664-4f0a-8465-2f5eb5fbe705".sections[0].regularHours[0].startTime') AS ubereats_start_time,
    JSON_VALUE(response, '$.data.menus."26bd579e-5664-4f0a-8465-2f5eb5fbe705".sections[0].regularHours[0].endTime') AS ubereats_end_time,
    STRUCT(
      b_name AS business_name,
      vb_name AS virtual_brand_name
    ) AS restaurant_details
  FROM
    `arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours`
),

GrubhubData AS (
  SELECT
    slug AS grubhub_slug,
    JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].from') AS grubhub_start_time,
    JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].to') AS grubhub_end_time,
    STRUCT(
      b_name AS business_name,
      vb_name AS virtual_brand_name
    ) AS restaurant_details
  FROM
    `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`
)

SELECT
  GrubhubData.grubhub_slug,
  CONCAT(GrubhubData.grubhub_start_time, ' - ', GrubhubData.grubhub_end_time) AS grubhub_business_hours,
  UberEatsData.ubereats_slug,
  CONCAT(UberEatsData.ubereats_start_time, ' - ', UberEatsData.ubereats_end_time) AS ubereats_business_hours,
  CASE
    WHEN GrubhubData.grubhub_start_time >= UberEatsData.ubereats_start_time
      AND GrubhubData.grubhub_end_time <= UberEatsData.ubereats_end_time THEN 'In Range'
    WHEN GrubhubData.grubhub_start_time < UberEatsData.ubereats_start_time
      OR GrubhubData.grubhub_end_time > UberEatsData.ubereats_end_time THEN 'Out of Range'
    ELSE 'Out of Range with 5 mins difference'
  END AS business_hour_mismatch
FROM UberEatsData
INNER JOIN GrubhubData
  ON UberEatsData.restaurant_details = GrubhubData.restaurant_details;
