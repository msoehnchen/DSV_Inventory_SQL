select
location,
WORK_ZONE,
ZONE_1,
SUBZONE_1,
SUBZONE_2,
LOCK_STATUS,
ZONEHEIGHT,
NEWZONETYPE,
NEWZONEHEIGHT,
NEWZONETYPE||NEWZONEHEIGHT NEWSUBZONE_1,
case
    when SUBZONE_1 = NEWZONETYPE||NEWZONEHEIGHT then 'NO'
    else 'YES'
end SUBZONE_1_CHANGED
from
(
    select
    ';'||LOCATION_ID location,
    WORK_ZONE,
    ZONE_1,
    SUBZONE_1,
    SUBZONE_2,
    LOCK_STATUS,
    FLOOR(HEIGHT*10)*10 ZONEHEIGHT,
    case
        when regexp_like(SUBZONE_1,'^(EURO|BLOK|BLOK)') then SUBSTR(SUBZONE_1,1,4)
        when regexp_like(SUBZONE_1,'^(D-BLOK|X-BLOK|D-EURO)') then substr(SUBZONE_1,1,6)
        when SUBZONE_1 is null and WIDTH < 0.85 then 'EURO'
        when SUBZONE_1 is null and WIDTH < 1.15 then 'BLOK'
        when SUBZONE_1 is null and WIDTH < 1.35 then 'X-BLOK'
        else 'OTHER'
    end NEWZONETYPE,
    
    case
        when FLOOR(HEIGHT*10)*10 >= 201 then '260'
        when FLOOR(HEIGHT*10)*10 >= 181 then '200'
        when FLOOR(HEIGHT*10)*10 >= 131 then '180'
        when FLOOR(HEIGHT*10)*10 >= 121 then '130'
        when FLOOR(HEIGHT*10)*10 >= 81 then '120'
        when FLOOR(HEIGHT*10)*10 >= 51 then '080'
        when FLOOR(HEIGHT*10)*10 <= 50 then '050'
        else 'OTHER'
    end NEWZONEHEIGHT
    from V_LOCATION
    where regexp_like(LOCATION_ID, '^1R(\d\d\d\d\d\w)')
    --and (SUBZONE_2 in ('NLXEROX'))
    --and (current_volume = 0 and current_weight = 0)
    and LOCK_STATUS <> 'Locked'
) locs