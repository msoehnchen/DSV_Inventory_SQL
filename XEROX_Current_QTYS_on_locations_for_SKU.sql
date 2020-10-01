select 
            
            i2.LOCATION,
            i2.SKU_ID,
            count(i2.TAG_ID) TAGS,
            --i2.CLIENT_ID,
            sum(i2.QTY_ON_HAND) QTY

from
(
    select
            i.TAG_ID,
            case 
                when length(i.LOCATION_ID) = 8 and substr(i.LOCATION_ID,1,1) = '1' then 'RACKING'
                else i.LOCATION_ID
            end LOCATION,
            i.SKU_ID,
            i.CLIENT_ID,
            i.QTY_ON_HAND
    from V_INVENTORY i
    where SKU_ID in('100S14276','C8001V/F')
    and i.location_id not like ('LANE%')
    and i.location_id not like ('5%')
) i2    

group by i2.LOCATION, i2.SKU_ID
order by i2.LOCATION