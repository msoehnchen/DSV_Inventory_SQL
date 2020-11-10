select 
    --locs.ZONE_1,
    locs.SUBZONE_2,
    locs.SUBZONE_1,
    count(locs.LOCATION_ID) EMPTY_LOCS
    
    --locs.WORK_ZONE,
    --locs.IS_EMPTY
from
(
    select
        LOCATION_ID,
        ZONE_1,
        SUBZONE_1,
        SUBZONE_2,
        WORK_ZONE,
        --LOCK_STATUS,
        --WIDTH,
        --DEPTH,
        --HEIGHT,
        --WEIGHT,
        case
            when CURRENT_VOLUME + CURRENT_WEIGHT = 0 then 1
            else 0
        end IS_EMPTY
    from V_location
    where LOCK_STATUS = 'UnLocked'
) locs
where locs.IS_EMPTY = 1
group by
    --locs.ZONE_1,
    locs.SUBZONE_1,
    locs.SUBZONE_2,
    --locs.WORK_ZONE,
    locs.IS_EMPTY
order by locs.subzone_2, locs.subzone_1