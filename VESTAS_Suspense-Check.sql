select
s.SKU_ID,
s.MOVE_DATE,
s.QTY_SUSPENSE,
s.STATUS,
nvl(i.QTY_STORAGE,0) QTY_STORAGE,
nvl(o.QTY_OUTBOUND,0) QTY_OUTBOUND


from
(
    select 
        SKU_ID,
        CLIENT_ID,
        nvl(sum(QTY_ON_HAND),0) QTY_SUSPENSE,
    
        case
            when sum(QTY_ON_HAND) > 0 then 'MISSING'
            else 'SURPLUS'
        end STATUS,
        to_number(substr(max(MOVE_DSTAMP) - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) MOVE_DATE
    from V_Inventory where location_id = 'SUSPENSE' and client_id = 'NLVESTAS'
    group by SKU_ID, CLIENT_ID
) s
left join
(
select
SKU_ID,CLIENT_ID,sum(QTY_ON_HAND) QTY_STORAGE
from V_INVENTORY where location_id <> 'SUSPENSE'
and location_id not like ('LANE%')
group by SKU_ID, CLIENT_ID
) i
on s.client_id = i.client_id and s.sku_id = i.sku_id
left join
(
select
SKU_ID,CLIENT_ID,sum(QTY_ON_HAND) QTY_OUTBOUND
from V_INVENTORY where location_id <> 'SUSPENSE'
and location_id like ('LANE%')
group by SKU_ID, CLIENT_ID
) o
on s.client_id = o.client_id and s.sku_id = o.sku_id
order by s.MOVE_DATE 