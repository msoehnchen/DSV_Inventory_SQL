select
location,
WORK_ZONE,
ZONE_1,
SUBZONE_1,
SUBZONE_2,
LOCK_STATUS,
LOCHEIGHT,
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
    -- round down the location-height
    FLOOR(HEIGHT*10)*10 LOCHEIGHT,
    
    case
        when regexp_like(SUBZONE_1,'^(EURO|BLOK|BLOK)') then SUBSTR(SUBZONE_1,1,4)
        when regexp_like(SUBZONE_1,'^(D-BLOK|X-BLOK|D-EURO)') then substr(SUBZONE_1,1,6)
        when SUBZONE_1 is null and WIDTH < 0.85 then 'EURO'
        when SUBZONE_1 is null and WIDTH < 1.15 then 'BLOK'
        when SUBZONE_1 is null and WIDTH < 1.35 then 'X-BLOK'
        else 'OTHER'
    end NEWZONETYPE,
    
    -- SET ZONE-HEIGHTS based on location-Height
    case
        when FLOOR(HEIGHT*10)*10 between 50 and 79 then '050'
        when FLOOR(HEIGHT*10)*10 between 80 and 119 then '080'
        when FLOOR(HEIGHT*10)*10 between 120 and 129 then '120'
        when FLOOR(HEIGHT*10)*10 between 130 and 179 then '130'
        when FLOOR(HEIGHT*10)*10 between 180 and 199 then '180'
        when FLOOR(HEIGHT*10)*10 between 200 and 259 then '200'
        when FLOOR(HEIGHT*10)*10 between 260 and 320 then '260'
        else 'OTHER'
    end NEWZONEHEIGHT
    from V_LOCATION
    -- choose all locations in 1R-Racking without SHELVING
    where regexp_like(LOCATION_ID, '^1R(\d\d\d\d\d\w)$')
    and LOCK_STATUS <> 'Locked'
) locs