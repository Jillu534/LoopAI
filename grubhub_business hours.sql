SELECT
   slug AS grubhub_slug,
   CONCAT(
     JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].from'),
     '-',
     JSON_VALUE(response, '$.today_availability_by_catalog.STANDARD_DELIVERY[0].to')
   ) AS grubhub_hours,
   STRUCT(
     b_name AS business_name,
     vb_name AS virtual_brand_name
   ) AS restaurant_details
 FROM
   `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`;