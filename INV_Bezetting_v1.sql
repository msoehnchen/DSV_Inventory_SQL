select
l.LOCATION_ID,
l.LEVELS,
l.ZONE_1,
l.SUBZONE_1,
l.SUBZONE_2,
l.LOCK_STATUS,
case
    when l.current_volume + l.alloc_volume + l.current_weight = 0 then '0'
    else '1'
end meas_hasInventory

from V_location l
where l.LOCK_STATUS <> 'Locked'
and REGEXP_LIKE(l.LOCATION_ID, '^1(A|B|C|D|E|F|Q|R|S)')
and l.LOCATION_ID not like '%LIJN%'