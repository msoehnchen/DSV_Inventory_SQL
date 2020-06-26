select *
from (
select CLIENT_ID, PRE_ADVICE_ID, STATUS, DUE_DSTAMP, to_number(substr(DUE_DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) EXCEL_DATE
from V_PRE_ADVICE_HEADER pa 
where pa.client_id = 'NLZEON' and pa.status = 'Hold' and pa.DUE_DSTAMP >= to_timestamp(:BeginDate_as_DD_MM_YYYY, 'DD/MM/YYYY')
) pah
left join
(
select PRE_ADVICE_ID, LINE_ID, HOST_PRE_ADVICE_ID, SKU_ID, CONFIG_ID, QTY_DUE,
    ceil(QTY_DUE / LPAD(CONFIG_ID,INSTR(CONFIG_ID,'E1P')-1)) QTYPAL

from V_PRE_ADVICE_LINE where client_id = 'NLZEON'
) pal


on pal.pre_advice_id = pah.PRE_ADVICE_ID

ORDER BY pah.due_dstamp