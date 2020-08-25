select 
    ZONE_1,
    SUBZONE_1,
    SUBZONE_2,
    count(LOCATION_ID) QTY_of_empty_locs
    --WORK_ZONE,
    --LOCK_STATUS,
    --VOLUME,
    --CURRENT_VOLUME,
    --ALLOC_VOLUME,
    --HEIGHT,
    --DEPTH,
    --WIDTH,
    --WEIGHT,
    --CURRENT_WEIGHT,
    --ALLOC_WEIGHT,
    --AISLE,
    --BAY,
    --LEVELS,
    --POSITION
from V_LOCATION
where CURRENT_VOLUME = 0
    and CURRENT_WEIGHT = 0
    and ALLOC_VOLUME = 0
    and ALLOC_WEIGHT = 0
    and LOCK_STATUS in ('UnLocked','InLocked')
    and REGEXP_LIKE(LOCATION_ID,'^1(A|B|C|D|E|F|Q|R|S)??????')
    
group by SUBZONE_2,SUBZONE_1,ZONE_1

order by ZONE_1, SUBZONE_2, SUBZONE_1