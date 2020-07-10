select
    zones.ZONE_1 LOCATIONZONE,
    zones.SUBZONE_1 SUBZONE_1,
    zones.SUBZONE_2 SUBZONE_2,
    case
        when locs.QTY_OF_LOCS is null then 0
        else locs.QTY_OF_LOCS
    end QTY_OF_LOCATIONS
from
(
    select 
        ZONE_1, SUBZONE_1, SUBZONE_2
    from V_location_zone
) zones
left join
(
    select 
        count(LOCATION_ID) QTY_OF_LOCS,
        ZONE_1,
        SUBZONE_1,
        SUBZONE_2
    from V_LOCATION
    group by ZONE_1, SUBZONE_1, SUBZONE_2
) locs
on zones.zone_1 = locs.zone_1 and zones.SUBZONE_1 = locs.SUBZONE_1 and zones.SUBZONE_2 = locs.SUBZONE_2