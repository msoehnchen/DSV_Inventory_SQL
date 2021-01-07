/*
   Shows all pallets which are on "wrong" locations. Means like Vestas-Pallets on Xerox-Locations.
        VMI-Pallets are filtered out.
*/

select
    loc.location_id "Location",
    loc.lock_status "Status",
    inv.sku_id "SKU",
    inv.Tag_id "TAG-ID",
    inv.client_id "SKU Client ID",
    LOC.SUBZONE_2 "Location Subzone 2",
    LOC.SUBZONE_1 "Location Subzone 1",
    LOC.zone_1 "Location Zone",
    LOC.WORK_ZONE "Work Zone",
    
    '                              ' "Note"

from
    (
    select i.sku_id, i.LOCATION_ID, i.CLIENT_ID, i.tag_id
    from V_inventory i
    ) inv
left JOIN
    (
    select l.subzone_2, l.subzone_1, l.zone_1, l.work_zone, l.location_id, l.lock_status
    from V_location l
    ) loc
on inv.location_id = loc.location_id

where inv.client_id != loc.subzone_2
and loc.subzone_2 not like '1A%'
and LOC.SUBZONE_2 not like '1B%'
and LOC.SUBZONE_2 not like '2B%'

and loc.subzone_2 not like '1C%'
and loc.subzone_2 not like '1D%'
and loc.subzone_2 not like '1E%'
and loc.subzone_2 not like '1F%'
and loc.subzone_2 not like '1Q%'
and loc.subzone_2 not like '1R%'
and loc.subzone_2 not like '1S%'
and loc.subzone_2 not like '290%'


and loc.subzone_2 not like 'ZIEGLER%'

and not (inv.client_id = 'NLFXG' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLVIS' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLHP' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLFFI' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLVESTAS' and loc.subzone_2 = 'NLBJC')
and not (inv.client_id = 'NLBJC' and loc.subzone_2 = 'NLVESTAS')

and not (INV.CLIENT_ID = 'NLETS')


order by inv.client_id, loc.subzone_2

