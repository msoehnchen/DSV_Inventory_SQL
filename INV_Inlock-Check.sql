SELECT
    LTRIM(LPAD(LOCATION_ID,2),'1') Hal,
    LOCATION_ID,
    ZONE_1,
    SUBZONE_1,
    SUBZONE_2,
    WORK_ZONE,
    LOCK_STATUS
FROM V_LOCATION
where LOCK_STATUS = 'InLocked'
    and REGEXP_LIKE(LOCATION_ID, '^1(A|B|C|D|E|F)')
    and ZONE_1 != 'DAMAGE'
    and SUBZONE_2 is not null
    
order by LOCATION_ID;