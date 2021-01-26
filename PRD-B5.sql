set verify off
set feedback off
SET SERVEROUTPUT ON
set linesize 800 -- set linesize very high, to avoind linebreaks that can kill the HTML



spool "K:\NL.Solutions.Venray\Inventory Control\18 - SQL\18.3 - Spoolfiles\Putaways001.html"

declare
    HEIGHTOFFSET float(3);
    WIDTHOFFSET float(3);
    STYLESHEET varchar(100);

begin
    STYLESHEET := 'K:\NL.Solutions.Venray\Inventory Control\19 - Templates\19.4 - HTML and CSS\InventoryReport.css';
    HEIGHTOFFSET := 1.0;
    WIDTHOFFSET := 0.5;
    
    DBMS_OUTPUT.PUT_LINE('
    <HTML>
        <HEAD>
            <title>Dashboard</title>
            <meta name="author" content="marcel.holl@nl.dsv.com">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta http-equiv="refresh" content="70"> 
            <link rel="stylesheet" href="'||STYLESHEET||'">
        </HEAD>
    <BODY>
    <DIV class="mastergrid">
    <DIV class="pageheader">
    <TABLE border="0" width="95%">
    <TR>
        <TD><img class="dsvlogo" src="K:\NL.Solutions.Venray\Inventory Control\19 - Templates\19.3 - Logos\DSV logo with payoff Left aligned WHITE.png"></TD>
        <TD><center>
            <P class="heading">Date of report: <font style="color:blue">' || TO_CHAR(SYSDATE,'DD/MM/YYYY') || '</font>   -   Time of report: <font style="color:blue">' || TO_CHAR(SYSDATE,'HH24:MI:SS') || '</FONT></P>
            <P class="subheading">User: <font style="color:blue">' || user || '</font></P><P class="subheading">(refresh in: <font id="countdown"></font> seconds)</P>
        </CENTER></TD>
        <TD><center><H1>Inventory Dashboard</H1><H6>version 1.0</H6></CENTER></TD>
    </TR>
    </TABLE>
    </DIV>
    <DIV class="pagecontent">
    
    <DIV class="tableFixHead">
    <HR>
    <TABLE class="data98">
    <THEAD>
    <TR class="hide-responsive">
    <TH colspan="4" class="header">SKU-DATA</TH>
    <TH colspan="4" class="header">Pallettype-DATA</TH>
    <TH class="header"></TH>
    <TH class="header"></TH>
    <TH colspan="3" class="header">Empty Locations</TH>
    </TR>
    <TR>
    <TH width="80px" class="header">CLIENT</TH>
    <TH width="100px" class="header">SKU</TH>
    <TH width="auto" class="header hide-responsive">DESCRIPTION</TH>
    <TH width="90px" class="header hide-responsive">PACK-CONFIG</TH>
    <TH width="100px" class="headersmall hide-responsive">PALLETTYPE</TH>
    <TH width="50px" class="headersmall hide-responsive">Ceiled WIDTH</TH>
    <TH width="50px" class="headersmall hide-responsive">Ceiled DEPTH</TH>
    <TH width="50px" class="headersmall hide-responsive">Ceiled HEIGHT</TH>
    <TH width="100px" class="header">Putaway Group</TH>
    <TH width="80px" class="header">QTY Palletts</TH>
    <TH width="80px" class="header">Groundlocs</TH>
    <TH width="80px" class="header">Highlocs</TH>
    <TH width="100px" class="header">Result</TH>
    </TR>
    </THEAD>
    ');
    
    FOR t IN (

SELECT CLIENT, SKU, DESCRIPTION, PACKCONF, PALTYPE, C_WIDTH, C_DEPTH, C_HEIGHT, PG, TAGS, GROUNDLOCS, HIGHLOCS, ENOUGH_LOCS, ENOUGH_LOCS_ORDERID FROM(
select -- FROM q2: here we sum the locations, and check if there are enough locations total
    q2.CLIENT_ID CLIENT,
    ';'||q2.SKU_ID SKU,
    q2.DESCRIPTION DESCRIPTION,
    q2.CONFIG_ID PACKCONF,
    q2.PALLET_CONFIG PALTYPE,
    q2.ceiled_width C_WIDTH,
    q2.ceiled_depth C_DEPTH,
    q2.ceiled_height C_HEIGHT,
    case
    when Q2.PUTAWAY_GROUP in ('GLORY01','VESTAS03') or (regexp_like(Q2.PUTAWAY_GROUP,'^(A|B|C)\w\d\d\d') and not regexp_like(Q2.PUTAWAY_GROUP,'^BU\d\d\d'))
        then '<font class="warning">'||Q2.PUTAWAY_GROUP||'</font>'
    when regexp_like(Q2.PUTAWAY_GROUP,'^BU\d\d\d')
        then '<font class="warninglow">'||Q2.PUTAWAY_GROUP||'</font>'
        else q2.putaway_group
    end PG,
    q2.QTY_OF_TAGS TAGS,
    sum(q2.FREE_GROUNDLOCATIONS) GROUNDLOCS,
    sum(q2.FREE_HIGHLOCATIONS) HIGHLOCS,
    case
        when regexp_like(Q2.PALLET_CONFIG,'^CRTN') then 'SHELF'
        when sum(q2.FREE_GROUNDLOCATIONS) + sum(q2.FREE_HIGHLOCATIONS) >= q2.QTY_OF_TAGS then 'OK'
        else 'NOT OK !!'
    end ENOUGH_LOCS,
        case
        when regexp_like(Q2.PALLET_CONFIG,'^CRTN') then 3
        when sum(q2.FREE_GROUNDLOCATIONS) + sum(q2.FREE_HIGHLOCATIONS) >= q2.QTY_OF_TAGS then 2
        else 1
    end ENOUGH_LOCS_ORDERID
from
(
    select -- FROM Q: here we make extra columns for groundlocs and highlocs
        q.CLIENT_ID,
        q.SKU_ID,
        q.DESCRIPTION,
        q.CONFIG_ID,
        q.PALLET_CONFIG,
        q.ceiled_width,
        q.ceiled_depth,
        q.ceiled_height,
        q.putaway_group,
        q.QTY_OF_TAGS,
        case
            when q.levelofloc = 'GROUNDLEVEL' then q.total_locs
            else 0
        end FREE_GROUNDLOCATIONS,
        case
            when q.levelofloc = 'HIGHLEVEL' then q.total_locs
            else 0 
        end FREE_HIGHLOCATIONS
        --q.total_locs,
        --q.levelofloc

    from
    (
        select
            inv.CLIENT_ID,
            inv.SKU_ID,
            inv.DESCRIPTION,
            inv.CONFIG_ID,
            inv.PALLET_CONFIG,
            --pal.width,
            ceil(pal.width*10)/10 ceiled_width,
            --pal.depth,
            ceil(pal.depth*10)/10 ceiled_depth,
            --pal.height,
            ceil(pal.height*10)/10 ceiled_height,
            sku.putaway_group,
            inv.QTY_OF_TAGS,
            sum(loc.Num_of_locs) total_locs,
            loc.levelofloc
            --loc.subzone_1,
            --loc.zone_1
        FROM
        (
            select -- getting all items from INBOUND lanes
                CLIENT_ID, SKU_ID, DESCRIPTION, CONFIG_ID, PALLET_CONFIG,count(TAG_ID) QTY_OF_TAGS
            from V_INVENTORY
            where (location_id like 'INB%' or location_id like 'NOTOLOC%' or location_id in ('CONFIG OUT'))
            and not location_id like 'INB-DCC%'
            group by CLIENT_ID, SKU_ID, DESCRIPTION, CONFIG_ID, PALLET_CONFIG
            order by CLIENT_ID, PALLET_CONFIG
        ) inv
        left join --merge with some sku-data
        (
        select
            CLIENT_ID, SKU_ID, PUTAWAY_GROUP
        from V_SKU
        ) sku
        on inv.CLIENT_ID = sku.CLIENT_ID and inv.SKU_ID = sku.SKU_ID
        left join --merge with some pallet-config-data
        (
        select
           CLIENT_ID, CONFIG_ID, HEIGHT, DEPTH, WIDTH, WEIGHT
        from V_PALLET_CONFIG
        ) pal
        on inv.client_id = pal.client_id and inv.pallet_config = pal.config_id
        left join -- merge with empty-location data
        (
        select -- getting empty locations and categorize in GROUND and HIGH level
            count(LOCATION_ID) Num_of_locs,
            case
                when substr(LOCATION_id,-1,1) = 'A' then 'GROUNDLEVEL'
                else 'HIGHLEVEL'
                end LEVELOFLOC,
            ZONE_1,
            SUBZONE_1,
            SUBZONE_2,
            --WORK_ZONE,
            --LOCK_STATUS,
            --CURRENT_VOLUME,
            --ALLOC_VOLUME,
            ceil(HEIGHT*10)/10 ceiled_height,
            ceil(DEPTH*10)/10 ceiled_depth,
            ceil(WIDTH*10)/10 ceiled_width
            --CURRENT_WEIGHT,
            --ALLOC_WEIGHT
        from V_location 
        where LOCK_STATUS = 'UnLocked' and length(location_id) = 8
            and current_weight = 0 and alloc_weight = 0 and current_volume = 0 and alloc_volume = 0
            and regexp_like(work_zone,'^30')
            and not work_zone = '30PICK'
        group by Zone_1,substr(LOCATION_id,-1,1),Subzone_1,Subzone_2,ceil(HEIGHT*10)/10,ceil(DEPTH*10)/10,ceil(WIDTH*10)/10

        ) loc
        -- combining conditions: decoding storer for VMI, also set tolerances for location dimensions, so we should not get too many locations that are way to big
        on decode(inv.client_id,'NLFXG','NLXEROX',
                                'NLFFI','NLXEROX',
                                'NLXEROX','NLXEROX',
                                'NLVIS','NLXEROX',
                                'NLHP','NLXEROX',
                                'NLNEDAP','NLNEDAP',
                                'NLVESTAS','NLVESTAS',
                                'NLGLORY','NLGLORY',
                                'NLZEON','NLZEON',
                                'NLBJC','NLBJC') = loc.subzone_2
            /** SETUP OF TOLERANCES AND SPECIAL PUTAWAY GROUPS **/
            and (ceil(pal.width*10)/10 between LOC.CEILED_WIDTH-WIDTHOFFSET and LOC.CEILED_WIDTH) --- standard: 0.2
            and (CEIL(PAL.depth*10)/10 between LOC.CEILED_DEPTH-0.7 and LOC.CEILED_DEPTH) --- standard: 0.7
            and (ceil(pal.height*10)/10 between LOC.CEILED_height-HEIGHTOFFSET and LOC.CEILED_height) --- standard: 0.5
            and regexp_like(LOC.LEVELOFLOC,(CASE when sku.putaway_group in ('VESTAS02G','GLORY-HVY','VESTAS01G') then 'GROUNDLEVEL'
                                                else 'GROUNDLEVEL|HIGHLEVEL' end))

        group by
            inv.CLIENT_ID,
            inv.SKU_ID,
            inv.DESCRIPTION,
            inv.CONFIG_ID,
            inv.PALLET_CONFIG,
            --pal.width,
            ceil(pal.width*10)/10,
            --pal.depth,
            ceil(pal.depth*10)/10,
            --pal.height,
            ceil(pal.height*10)/10,
            sku.putaway_group,
            inv.QTY_OF_TAGS,
            loc.levelofloc
            --loc.Num_of_locs
            --loc.subzone_1,
            --loc.zone_1

        --order by inv.client_id, inv.sku_id
    ) q
)q2
group by
    q2.CLIENT_ID,
    q2.SKU_ID,
    q2.DESCRIPTION,
    q2.CONFIG_ID,
    q2.PALLET_CONFIG,
    q2.ceiled_width,
    q2.ceiled_depth,
    q2.ceiled_height,
    q2.putaway_group,
    q2.QTY_OF_TAGS

order by ENOUGH_LOCS_ORDERID, Q2.CLIENT_ID, Q2.QTY_OF_TAGS
)
-- CLIENT, SKU, DESCRIPTION, PACKCONF, PALTYPE, C_WIDTH, C_DEPTH, C_HEIGHT, PG, TAGS, GROUNDLOCS, HIGHLOCS, ENOUGH_LOCS
    ) 
    loop
        DBMS_OUTPUT.PUT_LINE('<TR class="hover"><TD>'
        ||t.CLIENT
        || '</TD><TD>'
        ||t.SKU
        || '</TD><TD class="hide-responsive">'
        ||t.DESCRIPTION
        || '</TD><TD class="hide-responsive">'
        ||t.PACKCONF
        || '</TD><TD class="hide-responsive">'
        ||t.PALTYPE
        || '</TD><TD class="textright hide-responsive">'
        ||t.C_WIDTH
        || '</TD><TD class="textright hide-responsive">'
        ||t.C_DEPTH
        || '</TD><TD class="textright hide-responsive">'
        ||t.C_HEIGHT
        || '</TD><TD>'
        ||t.PG
        || '</TD><TD class="textright">'
        ||t.TAGS
        || '</TD><TD class="textright">'
        ||t.GROUNDLOCS
        || '</TD><TD class="textright">'
        ||t.HIGHLOCS
        || '</TD">'
        ||(case
            when t.ENOUGH_LOCS = 'OK' then '<TD class="resultok textcenter">OK</TD>'
            when t.ENOUGH_LOCS = 'NOT OK !!' then '<TD class="warning textcenter">NOT OK !!</TD>'
            when t.ENOUGH_LOCS = 'SHELF' then '<TD class="resultok textcenter">SHELF</TD>'
        end
        )
        || '</TR>');

    END LOOP;
    /** END OF PUTAWAY LOOP **/
    dbms_output.put_line('</TABLE><HR></DIV>');
        
    /** START OF STOCK-CHECK TABLE **/
    dbms_output.put_LINE('
        <DIV class="tableFixHead">
        <TABLE class="data50">
        <THEAD>
        <TR class="hide-responsive">
        <TH colspan="5" class="header">STOCK CHECKS in progress</TH>
        </TR>
        <TR>
        <TH width="100px" class="header">List ID</TH>
        <TH width="100px" class="header hide-responsive textcenter">Work Zone</TH>
        <TH width="80px" class="header textcenter">Client</TH>
        <TH width="80px" class="header textcenter">Locations</TH>
        <TH width="100px" class="header textcenter">Date of List</TH>
        </TR>
        </THEAD>
        <TBODY>
    ');
    
    /** START OF STOCK-CHECK LOOP **/
    FOR s in (
        select 
        LIST_ID,
        WORK_ZONE,
        VARIANCE_CHECK,
        max(CLIENT_ID) MAX_CLIENT,
        count(distinct LOCATION_ID) CTD_LOCATIONS,
        TO_CHAR(max(TASK_DATE),'YYYY/MM/DD HH24:MI') MAX_DATE
        from V_STOCK_CHECK_TASKS where LIST_ID is not null
        group by LIST_ID, WORK_ZONE, STATUS, VARIANCE_CHECK
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('
            <TR class="hover">
                <TD>'||s.LIST_ID||'</TD>
                <TD class="hide-responsive textcenter">'||s.WORK_ZONE||'</TD>
                <TD class="textcenter">'||s.MAX_CLIENT||'</TD>
                <TD class="textcenter">'||s.CTD_LOCATIONS||'</TD>
                <TD class="textcenter">'||s.MAX_DATE||'</TD>
            </TR>              
            ');
    END LOOP;
    /** END OF Stock Check LOOP **/
    dbms_output.put_line('</TBODY></TABLE>');
    

    DBMS_OUTPUT.PUT_LINE('
    </DIV>
    </DIV> <!-- End of class pagecontent -->
    <DIV class="pagefooter">
    <HR>
        <TABLE width="100%"><TR>
        <TD class="footertext" width="20%">autorefresh in: <font id="countdown2"></font> seconds</TD>
        <TD class="footertext textright" width="80%">created using Report-script:   <font style="font-style:italic">"Inbound vs. empty Locations (HTML)"</font></TD>
        </TR></TABLE>
    </DIV>
        
            <script type="text/JavaScript">
            <!--
            (function countdown(remaining) {
                 if(remaining <= 0)
                 location.reload(true);
                document.getElementById(''countdown'').innerHTML = remaining;
                document.getElementById(''countdown2'').innerHTML = remaining;
                setTimeout(function(){ countdown(remaining - 1); }, 1000);
            })(60); // 60 seconds
            //   -->
            </script>
    
    </DIV> <!-- end of mastergrid -->
    </BODY>
    ');
    
end;
/
SPOOL OFF