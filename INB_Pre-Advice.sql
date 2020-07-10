SELECT
    PAH.YARD_CONTAINER_ID,
    PAH.PRE_ADVICE_ID,
    PAH.OWNER_ID,
    PAH.STATUS,
    TO_CHAR(PAH.DUE_DSTAMP, 'DD/MM/YYYY HH:MM:SS') DUE_DATE,
    PAL.SKU_ID,
    PAL.QTY_DUE,
    PAL.PALLET_CONFIG,
    S.DESCRIPTION,
    S.USER_DEF_TYPE_5,
    S.NEW_PRODUCT,
    S.PUTAWAY_GROUP,
    PAL.CONFIG_ID 
FROM V_PRE_ADVICE_HEADER PAH 
JOIN V_PRE_ADVICE_LINE PAL
    ON PAH.PRE_ADVICE_ID = PAL.PRE_ADVICE_ID 
JOIN V_SKU S 
    ON PAL.SKU_ID = S.SKU_ID AND PAL.CLIENT_ID = S.CLIENT_ID 
WHERE PAH.CLIENT_ID NOT IN ('NLNEWBAL') 
    AND PAH.STATUS NOT IN ('Complete') 
    AND TRUNC(PAH.DUE_DSTAMP) > SYSDATE - 4 
    AND TRUNC(PAH.DUE_DSTAMP)< SYSDATE + 1          

ORDER BY PAH.OWNER_ID,PAH.DUE_DSTAMP, PAH.YARD_CONTAINER_ID;
