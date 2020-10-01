select
    inv_main.LOCATION_ID,
    ser.TAG_ID,
    ser.SKU_ID,
    ser.SN_INSTOCK,
    ' ' "CHECK",
    ser.SN_PICKED,
    ' ' "CHECK2",
    ser.PALLET_ID,
    --inv.PALLET_ID,
    inv.LOCATION_ID LOCATION_PICKED_TO
    --inv_main.TAG_ID,
    
from
(
    select
        s.TAG_ID,
        s.SKU_ID,
        --s.SERIAL_NUMBER,
        --s.STATUS,
        --s.RECEIPT_DSTAMP,
        case
            when s.pallet_id is not null then s.SERIAL_NUMBER
            else null
        end SN_PICKED,
        case
            when s.pallet_id is null then s.SERIAL_NUMBER
            else null
        end SN_INSTOCK,
        s.PALLET_ID
       
    from V_SERIAL_NUMBER s
    where
        (s.client_id = 'NLGLORY' and s.STATUS = 'I')
        --and s.TAG_ID = 'G020193684' --TEMP FILTER
) ser
left join
(
select i.pallet_id, i.location_id from v_inventory i where i.client_id = 'NLGLORY' and i.LOCATION_ID not like ('1%')
) inv
on ser.pallet_id = inv.pallet_id
left join
(
select i.tag_id, i.location_id from v_inventory i where i.client_id = 'NLGLORY' and (i.LOCATION_ID like ('1%') or i.LOCATION_ID like ('I%') OR i.LOCATION_id in ('NONCONFORM','GGSINSPECT','GGSTRAIN','CONFIG OUT'))
)inv_main
on ser.tag_id = inv_main.tag_id

group by 
    inv_main.LOCATION_ID,
    ser.TAG_ID,
    ser.SKU_ID,
    ser.SN_PICKED,
    ser.SN_INSTOCK,
    ser.PALLET_ID,
    inv.LOCATION_ID

order by inv_main.Location_id, ser.tag_id, ser.SN_INSTOCK,ser.SN_PICKED, inv.location_id