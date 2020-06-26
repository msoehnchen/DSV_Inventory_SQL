select
    pah.CLIENT_ID,
    PAH.PRE_ADVICE_ID,
    STATUS,
    DUE_DSTAMP,
    EXCEL_DATE,
    LINE_ID,
    PAL.SKU_ID,
    pal.CONFIG_ID,
    pal.QTY_DUE,
    QTY_PERPALLET,
    SUMPALLETS,
    USER_DEF_TYPE_7,
    MIN_QTYPERPALLET,
    ceil(pal.QTY_DUE / MIN_QTYPERPALLET) MAXSUMPALLETS
from (
    select CLIENT_ID, PRE_ADVICE_ID, STATUS, DUE_DSTAMP, to_number(substr(DUE_DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) EXCEL_DATE
    from V_PRE_ADVICE_HEADER pa 
    where pa.client_id = 'NLZEON' and pa.status = 'Hold' and pa.DUE_DSTAMP >= to_timestamp(:BeginDate_as_DD_MM_YYYY, 'DD/MM/YYYY')
) pah
left join
(
    select PRE_ADVICE_ID, LINE_ID, HOST_PRE_ADVICE_ID, SKU_ID, CONFIG_ID, QTY_DUE,
        LPAD(CONFIG_ID,INSTR(CONFIG_ID,'E1P')-1) QTY_PERPALLET,
        ceil(QTY_DUE / LPAD(CONFIG_ID,INSTR(CONFIG_ID,'E1P')-1)) SUMPALLETS
    
    from V_PRE_ADVICE_LINE where client_id = 'NLZEON'
) pal
on pal.pre_advice_id = pah.PRE_ADVICE_ID
left join
(
    select SKU_ID, USER_DEF_TYPE_7 from V_SKU where CLIENT_ID = 'NLZEON'
) sku
on sku.SKU_ID = pal.SKU_ID
left join
(
select SKU_ID, min(LPAD(CONFIG_ID,INSTR(CONFIG_ID,'E1P')-1)) MIN_QTYPERPALLET from V_SKU_SKU_CONFIG where client_id = 'NLZEON'
group by SKU_ID
) config
on pal.SKU_ID = config.SKU_ID

ORDER BY pah.due_dstamp

