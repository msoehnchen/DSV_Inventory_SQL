select 
it.CODE,
it.FROM_LOC_ID,
it.TO_LOC_ID,
it.CLIENT_ID,
it.SKU_ID,
it.TAG_ID,
it.DSTAMP,
it.REASON_ID,
it.USER_ID,
it.PALLET_CONFIG,

--loc.LOCATION_ID,
loc.ZONE_1,
loc.SUBZONE_1,
loc.SUBZONE_2,



CASE
    when loc.WIDTH <= 0.8 then 'EURO'
    when loc.WIDTH <= 1.1 then 'BLOK'
    when loc.WIDTH <= 1.3 then 'XWBLOK1'
    when loc.WIDTH <= 1.5 then 'XWBLOK2'
    else 'XWF'
END KAT_BREEDTE,

CASE
    when loc.DEPTH <= 0.9 then '090'
    when loc.DEPTH <= 1.2 then '120'
    when loc.DEPTH <= 1.3 then '130'
    else 'groter 130'
END KAT_DIEPTE,

CASE
    when loc.HEIGHT <= 0.5 then '050'
    when loc.HEIGHT <= 1.05 then '100'
    when loc.HEIGHT <= 1.5 then '150'
    when loc.HEIGHT <= 1.8 then '180'
    when loc.HEIGHT <= 2 then '200'
    when loc.HEIGHT <= 2.3 then '230'
    else 'groter 230'
END KAT_HOOGTE

--loc.WIDTH,
--loc.DEPTH
--loc.HEIGHT


from V_INVENTORY_TRANSACTION it, V_LOCATION loc
where it.code = 'Putaway'
and it.DSTAMP between 
    to_TIMESTAMP('15/07/2020', 'DD/MM/YYYY') and
    to_TIMESTAMP('16/07/2020', 'DD/MM/YYYY')
and it.TO_LOC_ID = loc.location_id
