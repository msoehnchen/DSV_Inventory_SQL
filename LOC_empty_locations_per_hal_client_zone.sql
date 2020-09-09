select
substr(AISLE,2,1) HAL,
SUBZONE_2,
SUBZONE_1,
decode(LOCK_STATUS,'UnLocked',' ','InLocked','In-Locked') Is_LOCKED,
count(LOCATION_ID) QTY_EMPTY_LOCS

from V_LOCATION
where (alloc_volume = 0 and current_volume = 0 and alloc_weight = 0 and current_weight = 0 and length(location_id) = 8 and REGEXP_LIKE(location_id,'^1') and lock_status in ('UnLocked','InLocked'))
group by substr(AISLE,2,1), SUBZONE_2, SUBZONE_1, LOCK_STATUS

order by substr(AISLE,2,1), SUBZONE_2, SUBZONE_1, LOCK_STATUS desc