/* Query 1: Summary in text-format */
select
'We have ' || count(ct1.LOCATION_ID) || ' locations with ' || ct1.CT_TAGS || ' Pallet-IDs.' "Result A-HAl (VESTAS)"
from
(
    select count(TAG_ID) "CT_TAGS", LOCATION_ID from V_INVENTORY where LOCATION_ID like '1A%' and CLIENT_ID = 'NLVESTAS'
    GROUP BY LOCATION_ID
) ct1
group by ct1.CT_TAGS
order by ct1.CT_TAGS
;

/* Query 2: Overzicht amount of TAGs per location */
select count(TAG_ID) "Count of TAGS", LOCATION_ID "LOCATION" from V_INVENTORY where LOCATION_ID like '1A%' and CLIENT_ID = 'NLVESTAS'
GROUP BY LOCATION_ID
;