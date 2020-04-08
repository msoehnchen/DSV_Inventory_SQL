select 
    it.FROM_LOC_ID,
    it.TO_LOC_ID,
    it.SKU_ID,
    it.TAG_ID,
    it.CONTAINER_ID,
    to_number(substr(it.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) DATEVALUE,
    it.REFERENCE_ID,
    it.PALLET_CONFIG,
    it.CONFIG_ID,
    it.ORIGINAL_QTY,
    loc.PICK_FACE,
    loc.LOC_TYPE
from V_inventory_transaction it
join V_location loc on it.from_loc_id = loc.location_id
where it.CLIENT_ID = 'NLNEDAP'
and it.FROM_LOC_ID not in ('1RVIRT1A')
and it.FROM_LOC_ID not like ('1Q5%') 
and it.FROM_LOC_ID not like ('%AA') 
and it.FROM_LOC_ID not like ('%BB')
and it.config_id not in ('1E1P')
and it.CODE = 'Pick'
and trunc(it.DSTAMP) > sysdate - 30
and REGEXP_LIKE(it.FROM_LOC_ID, '^1(Q|R|S)')
