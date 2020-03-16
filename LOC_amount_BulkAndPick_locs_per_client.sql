--    LOCATIONS - quantity of Bulk and Pick locations per Client         --
--              06-03-2020 by marcel.holl@nl.dsv.com                     --
-- --------------------------------------------------------------------- --
select
    to_number(substr(SYSDATE - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) "Serial Date",
    locs."CLIENT",
    locs."LOCATION TYPE",
    to_number(substr(SYSDATE - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2)||locs."CLIENT"||locs."LOCATION TYPE" "Helper",
    sum(locs."TOTAL LOCATIONS") "TOTAL LOCATIONS (not Locked)"
from
(
    select
        locs."CLIENT",
        case
            when locs."LOCATION ZONE" in ('30SHELF', '30PICK') then 'PICK'
            when locs."LOCATION ZONE" in ('30BLOK', '30STORAGE', '30BULK') then 'BULK'
            else 'different'        
        end "LOCATION TYPE",
        locs."TOTAL LOCATIONS"
    from
    (

/* Combined (RACK + BLOCK) locations */
select 
    combined."CLIENT",
    combined."LOCATION ZONE",
    sum(combined."TOTAL LOCATIONS") "TOTAL LOCATIONS"
from
(
    /* Regular locations */
    select
        loc.SUBZONE_2 "CLIENT",
        loc.WORK_ZONE "LOCATION ZONE",
        count(loc.LOCATION_ID) "TOTAL LOCATIONS"
    from V_LOCATION loc
    where loc.SUBZONE_2 in ('NLVESTAS', 'NLGLORY','NLNEDAP') --Set CLIENTS here
        and loc.LOCK_STATUS != 'Locked'
    group by loc.SUBZONE_2, loc.WORK_ZONE
UNION ALL
    /* BLOCKSTACK locations */
    select
        case
            when loc.SUBZONE_2 like '1Q%' then 'NLNEDAP' -- set Client based on location
            when loc.SUBZONE_2 like '1S%' then 'NLNEDAP' -- set Client based on location
            when loc.SUBZONE_2 like '1A%' then 'NLVESTAS' -- set Client based on location
        else loc.SUBZONE_2 
        end "CLIENT",
        loc.WORK_ZONE "LOCATION ZONE",
        count(loc.LOCATION_ID) "TOTAL LOCATIONS"
    from V_LOCATION loc
    where loc.WORK_ZONE in ('30BLOK') -- include Blockstacks
        and loc.LOCK_STATUS != 'Locked'
    group by loc.SUBZONE_2, loc.WORK_ZONE
) combined

where combined."CLIENT" in ('NLVESTAS','NLGLORY','NLNEDAP')

group by combined."CLIENT", combined."LOCATION ZONE"

) locs

) locs
group by locs."CLIENT",locs."LOCATION TYPE"
order by locs."CLIENT"
