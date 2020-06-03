select 
    pt.CLIENT_ID,
    pt.CONFIG_ID,
    count(DISTINCT SKU.SKU_ID)"USED in SKUS"

from (

select
    CLIENT_ID, CONFIG_ID
from V_PALLET_CONFIG pt
where CLIENT_ID in ('NLXEROX','NLFXG')

) pt
LEFT join
(
select
    CLIENT_ID, SKU_ID, USER_DEF_TYPE_7
from V_SKU sku
where CLIENT_ID in ('NLXEROX','NLFXG')
) sku
on pt.CLIENT_ID = sku.CLIENT_ID and pt.CONFIG_ID = sku.USER_DEF_TYPE_7


group by pt.CLIENT_ID,pt.config_id

order by "USED in SKUS" desc