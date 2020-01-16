select
    ord.REFERENCE_ID "SO number",
    ord.SKU_ID "item number",
    sum(ord.UPDATE_QTY) "QTY",
    ord.CONDITION_ID "status HO3",
    max(TO_CHAR(pick.LAST_PICK, 'DD-MM-YYYY')) "Pick date",
    ord."Ship date",
    case
        when upper(max(ord.notes)) like 'WO%' then max(ord.notes)
        else null
    end "WO note" 
    
from
(
    select
        ord.REFERENCE_ID,
        ord.SKU_ID,
        ord.UPDATE_QTY,
        ord.CONDITION_ID,
        TO_CHAR(ord.DSTAMP, 'DD-MM-YYYY') "Ship date",
        ord.pallet_id,
        ord.Notes
    
    from
    (
        select
           FROM_LOC_ID, SKU_ID, UPDATE_QTY,CONDITION_ID, DSTAMP, CONSIGNMENT, REFERENCE_ID, NOTES, CUSTOMER_ID, SHIPMENT_NUMBER, PALLET_ID
        from V_inventory_transaction 
        where CLIENT_ID = 'NLGLORY'
        and code like 'Shipment'
        and FROM_LOC_ID <> 'CONF FIN'
        and DSTAMP <= to_timestamp('31-12-2019', 'DD/MM/YYYY')
        UNION
        select 
           FROM_LOC_ID, SKU_ID, UPDATE_QTY, CONDITION_ID, DSTAMP, CONSIGNMENT, REFERENCE_ID, NOTES, CUSTOMER_ID, SHIPMENT_NUMBER, PALLET_ID
        from V_inventory_transaction_arc
        where CLIENT_ID = 'NLGLORY'
        and code like 'Shipment'
        and FROM_LOC_ID <> 'CONF FIN'
        and DSTAMP >= to_timestamp('01-01-2019', 'DD/MM/YYYY')    
    ) ord
)ord
left join
(
    select 
        pick.REFERENCE_ID,
        pick.SKU_ID,
        --pick.TAG_ID,
        max(pick.LAST_PICK) "LAST_PICK"
    from
    (
        select 
        REFERENCE_ID, max(CODE), max(CLIENT_ID),FROM_LOC_ID, TAG_ID, SKU_ID, max(DSTAMP) "LAST_PICK",to_number(substr(max(DSTAMP) - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) "LAST PICK EXCEL" 
        from V_INVENTORY_TRANSACTION_ARC
        where CODE = 'Pick'
            and CLIENT_ID = 'NLGLORY'
        group by REFERENCE_ID, FROM_LOC_ID, TAG_ID, SKU_ID 
    UNION all
        select 
        REFERENCE_ID, max(CODE), max(CLIENT_ID),FROM_LOC_ID, TAG_ID, SKU_ID, max(DSTAMP) "LAST_PICK",to_number(substr(max(DSTAMP) - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) "LAST PICK EXCEL" 
        from V_INVENTORY_TRANSACTION
        where CODE = 'Pick'
            and CLIENT_ID = 'NLGLORY'
        group by REFERENCE_ID, FROM_LOC_ID, TAG_ID, SKU_ID
    ) pick
    group by pick.REFERENCE_ID, pick.SKU_ID
) pick

on ord.REFERENCE_ID = pick.REFERENCE_ID and ord.SKU_ID = pick.SKU_ID
group by ord.REFERENCE_ID, ord.SKU_ID, ord.CONDITION_ID, ord."Ship date"
order by ord."Ship date", ord.REFERENCE_ID