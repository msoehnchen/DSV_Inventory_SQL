/**
  -- --------------------------------------------------------------------- -- 
  --    INVENTORY SUMMARY PER LOC, incl empty locs and multiple SKUS       --
  --            13/11/2019 by marcel.sohnchen@nl.dsv.com                   --
  -- --------------------------------------------------------------------- -- 
**/
SELECT
    l.location_id "LOCATION",
    MAX(l.lock_status) "LOCK STATUS",
               
-- count the total of different SKUS and return a readable value instead of a number
    CASE
            WHEN COUNT(DISTINCT i.sku_id) = 1 THEN 'single'
            WHEN COUNT(DISTINCT i.sku_id) > 1 THEN 'multiple'
            ELSE ''
        END
    "SKUS",

-- count the total of different SKUS and return the number
    COUNT(DISTINCT i.sku_id) "COUNT OF SKUS",
    SUM(i.qty_on_hand) "TOTAL QTY",
    SUM(i.qty_allocated) "TOTAL ALLOCATED",
        --max(l.COUNT_DSTAMP) "orig DSTAMP", -- not needed
        -- Function to convert Timestamp to Excel's numeric datevalue
    substr(MAX(l.count_dstamp) - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5) + 2 "COUNTDATE Datevalue",
    TO_CHAR(MAX(l.count_dstamp),'DD/MM/YYYY') "COUNTDATE String",
    MAX(i.client_id) "CLIENT ID",
    MAX(l.zone_1) "LOCATION ZONE",
    MAX(l.subzone_1) "SUBZONE 1",
    MAX(l.subzone_2) "SUBZONE 2"
FROM
    v_inventory i
    RIGHT JOIN v_location l ON i.location_id = l.location_id
-- INPUT FIELD FOR LOCATION_ID
-- use wildcard operator %
-- Example 1C08%AA or BU0%
WHERE
    l.location_id LIKE upper(:location_or_range_of_location)
    --and l.LOCK_STATUS != 'Locked'
    AND   l.zone_1 != 'UNUSED'
GROUP BY
    l.location_id
ORDER BY
    l.location_id;
