        select
           FROM_LOC_ID, SKU_ID, UPDATE_QTY,CONDITION_ID, to_number(substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) RECEIPTDATE, REFERENCE_ID, NOTES, TAG_ID
        from V_inventory_transaction 
        where CLIENT_ID = 'NLGLORY'
        and code like 'Receipt'
        and FROM_LOC_ID <> 'CONF FIN'
        and DSTAMP >= to_timestamp('28-01-2020', 'DD/MM/YYYY')
        and DSTAMP <= to_timestamp('08-02-2020', 'DD/MM/YYYY')
        UNION
        select 
           FROM_LOC_ID, SKU_ID, UPDATE_QTY, CONDITION_ID, to_number(substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) RECEIPTDATE, REFERENCE_ID, NOTES, TAG_ID
        from V_inventory_transaction_arc
        where CLIENT_ID = 'NLGLORY'
        and code like 'Receipt'
        and FROM_LOC_ID <> 'CONF FIN'
        and DSTAMP >= to_timestamp('28-01-2020', 'DD/MM/YYYY')
        and DSTAMP <= to_timestamp('08-02-2020', 'DD/MM/YYYY')
