/*
   Shows all pallets which are on "wrong" locations. Means like Vestas-Pallets on Xerox-Locations.
        VMI-Pallets are filtered out.
*/

select
    loc.location_id "Location",
    inv.sku_id "SKU",
    inv.Tag_id "TAG-ID",
    inv.client_id "SKU Client ID",
    loc.subzone_2 "Location Subzone 2",
    '                              ' "Note"

from
    (
    select i.sku_id, i.LOCATION_ID, i.CLIENT_ID, i.tag_id
    from V_inventory i
    ) inv
left JOIN
    (
    select l.subzone_2, l.location_id
    from V_location l
    ) loc
on inv.location_id = loc.location_id

where inv.client_id != loc.subzone_2
and loc.subzone_2 not like '1A%'
and loc.subzone_2 not like '1B%'
and loc.subzone_2 not like '1C%'
and loc.subzone_2 not like '1Q%'
and loc.subzone_2 not like '1S%'
and loc.subzone_2 not like '290%'


and loc.subzone_2 not like 'ZIEGLER%'

and not (inv.client_id = 'NLFXG' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLVIS' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLHP' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLFFI' and loc.subzone_2 = 'NLXEROX')
and not (inv.client_id = 'NLVESTAS' and loc.subzone_2 = 'NLBJC')
and not (inv.client_id = 'NLBJC' and loc.subzone_2 = 'NLVESTAS')


order by inv.client_id, loc.subzone_2

