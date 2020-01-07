--    LOCATIONS - quantity of Bulk and Pick locations per Client         --
--            19/11/2019 by marcel.sohnchen@nl.dsv.com                   --
-- --------------------------------------------------------------------- --
select
    locs."CLIENT",
    locs."LOCATION TYPE",
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
        select
            loc.SUBZONE_2 "CLIENT",
            loc.WORK_ZONE "LOCATION ZONE",
            count(loc.LOCATION_ID) "TOTAL LOCATIONS"
        from V_LOCATION loc
        where loc.SUBZONE_2 in ('NLVESTAS', 'NLGLORY') --Set CLIENTS here
            and loc.LOCK_STATUS != 'Locked'

        group by
            loc.SUBZONE_2, loc.WORK_ZONE
    ) locs
) locs
group by locs."CLIENT",locs."LOCATION TYPE"
order by locs."CLIENT"
