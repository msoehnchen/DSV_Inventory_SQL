set verify off
set feedback off
SET SERVEROUTPUT ON
set linesize 800 -- set linesize very high, to avoind linebreaks that can kill the HTML



spool "K:\NL.Solutions.Venray\Inventory Control\18 - SQL\18.3 - Spoolfiles\Dashboard001.html"

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
    <P class="sectiontitle">Putaways vs. Locations</P>
    <DIV class="tableFixHead">    
    <TABLE class="data98">
    <THEAD>
    <!-- Hide this
    <TR class="hide-responsive">
    <TH colspan="4" class="header">SKU-DATA</TH>
    <TH colspan="4" class="header">Pallettype-DATA</TH>
    <TH class="header"></TH>
    <TH class="header"></TH>
    <TH colspan="3" class="header">Empty Locations</TH>
    </TR>
    -->
    <TR>
    <TH width="80px" class="header">CLIENT</TH>
    <TH width="180px" class="header">SKU</TH>
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
    dbms_output.put_line('
    </TABLE>
    
    </DIV>
    <DIV class="devider"><HR></DIV>');
        
    /** START OF STOCK-CHECK TABLE **/
    dbms_output.put_LINE('
        <P class="sectiontitle">Stock Checks in progress</P>
        <DIV class="tableFixHead">
        <TABLE class="data50">
        <THEAD>
        <!-- hide this
        <TR class="hide-responsive">
        <TH colspan="5" class="header">STOCK CHECKS in progress</TH>
        </TR>
        -->
        <TR>
        <TH width="110px" class="header">List ID</TH>
        <TH width="80px" class="header">User</TH>
        <TH width="150px" class="header hide-responsive textcenter">Work Zone</TH>
        <TH width="100px" class="header textcenter">Client</TH>
        <TH width="80px" class="header textcenter">Locations</TH>
        <TH width="200px" class="header textcenter">Date of List</TH>
        </TR>
        </THEAD>
        <TBODY>
    ');
    
    /** START OF STOCK-CHECK LOOP **/
    FOR s in (
select
LIST_ID, max(USER_ID) USER_ID, max(USER_NAME) USER_NAME, max(INPROGRESSLOC) INPROGRESSLOC, min(IDLETIME) IDLETIME, WORK_ZONE, max(MAX_CLIENT) MAX_CLIENT, count(distinct CTD_LOCATIONS) CTD_LOCATIONS, min(MIN_DATE) MIN_DATE
from
(
        select 
        LIST_ID,
        USER_ID USER_ID,
        DECODE(USER_ID, '75RAPI','Ralf Piepers','72ADNO','Adrian Nowak','72DABR','Daniel Brodawski','72DAZA','Daniel Zapotoczny','72DONA','Dominik Nawlicki','72ERZW','Erica Zwamen','72IVZH','Ivanov Zhivko','72JARO','Jake Rongen','72JOVE','Joey van ECK','72NEDA','Nel Danen','72RAZA','Rafal Zalewski','75ADAD','Adam Adamek','75AGJA','Agnieszka Jankowska','75AHBO','Ahmed Boghrissi','75ALKU','Alicia Kuijer','75ALLA','Aleksandra Laskowska','75ALMA','Albert van der Mark','75ALNA','Aleksandra Nawrocka','75ANBA','Andrzej Barczyk','75ANCI','Aneta Cislo','75ANGG','Angelique de Groote','75ANHY','Anna Hydzik','75ANIW','Andrzej Iwanowski','75ANKA','Anna Kapuscinska','75ANKR','Angelo Kraus','75ANKU','Andrea Kutsch','75ANPE','Andra Peneoas','75ANPR','Anetta Przybylska','75ANSC','Andre Schlogl','75ANTA','Anna Tanistra-Biber','75ANVZ','Anita van Zanten','75BAMA','Bartozs Mackowiak','75BAWO','Bartosz Wolowski','75BOBR','Bokretsien Brhane','75BOMI','Bob van Mil','75CACO','Catia Costa','75CALO','Carlos Lopes','75CEKA','Cemal Kaya','75CHFL','Christofer Folkesson','75CHWE','Chris vd Weem','75CIHE','Cindy Hendriks-Emonts','75COEL','Connie Elsenbruch','75COHE','Corina Hermans','75CUVE','Customs Venray','75DABA','Dagmara Baczkowska','75DAHR','David Hermsen','75DAKO','Daniel Korpal','75DAKU','Dawid Kuc','75DARA','Dana Raytzig','75DASA','Daniel Salajczyk','75DEIL','Denitsa Ilieva','75DERE','Desiree Reinders','75DIL1','Diana Lutger','75DMSM','Dmitrijs Smirnovs','75DOST','Dolinda Stoks','75DOTO','Dominika Tomaszewska','75DRSW','Dorota Siwak','75DSTA','Donny Staphorst','75EDDO','Edwin Dollenkamp','75EDDU','Edyta Dukielska','75EDWE','Ed van Wegberg','75EDWI','Eduard Wiebe','75ELHE','Elles Hendriks','75EMBE','Emil Beelen','75EMMC','Emmy Cornelissen','75EMPA','Emilia Pawlewska','75ERBU','Ernest Buddiger','75ETPE','Etin Petrochi','75FEBR','Federico Brando','75FIMO','Filip Moczarski','75FLIS','Florin Istrate','75FRST','Fred Stevens','75GICL','Gillian Claessens','75GIHO','Gideon van Houten','75GIMO','Girmay Mokenen','75GIUP','Gints Upenieks','75GIWI','GIOVANNI WIJNEN','75GLRA','Glenn Ratcliff','75GRKE','Grzegorz Kedzia','75GRKO','Gratsiela Koseva','75GRSM','Grzegorz Smalira','75GUBE','Guus Beekhof','75HABO','Hai Bos','75HAHE','Harry Hendriks','75HASC','Hans Schreurs','75HASE','Hans Seykens','75HAWE','Hans Westheim','75HEHE','Henrie Hendriks-Jacobs','75HELE','Herman Lemmens','75HEPO','Herman Poulissen','75HOTA','Hosam Tawakalna','75IGWI','Igor Willer','75INGL','Inbound Glory','75IRHE','Iris Hermsen','75IWTO','Iwona Torzewska','75JABU','Janin','75JACH','Jacky Hendriks','75JADR','Janusz Draszewski','75JAHE','Jan Hendriks','75JAJA','Jakub Jakubowski','75JAKE','Jaan Keijmes','75JAST','Jack Stelte','75JIVE','Jim van Eijk','75JODA','Joanna Dabek','75JOLE','Joao Lemos Ludgero','75JOOT','Joop van Otterdijk','75JOST','Joachim Stucki','75JOWI','Joyce Wilms','75JUMA','Juozas Markevicius','75JUNC','Juan Antonio Nchamba','75JUPL','Justyna Plecner','75KABO','Katarzyna Borowiak','75KARA','Kamil Rams','75KAST','Kamil Staporek','75KEMA','Kevin Maassen','75KHJE','Khaled Jelali','75KIBA1','Kinga Barzowska','75KIHE','Kim Hennesen','75KLHA','Klaus Dieter Haag','75KLKA','Klaus Kazmierczak','75KMKM','Kamil Kaminski','75KOLI','Koen van der Linden','75KOPU','Koos Putker','75KOTO','Konrad Tomaszewski','75KRBL','Krysztof Blaszczuk','75KRZD','Krystian Zdrokowski','75LABE','Laszlo Berecz','75LEGR','Leon Gramser','75LEMC','Lenhard Mclarty','75LEPE','Leandro Pereira','75LERU','Lenka Rutten','75LINE','Lian Nellissen','75LITE','Lia Tebarts','75LOAL','Loris Alfieri','75LOPL','Lyobomir Peleev','75LUMI','Lukasz Miszewski','75LUSC','Ludwik Scibisz','75MAAB','Mana Abraham','75MABE','Max Beterams','75MAG1','Magdalena Golke','75MAGL','Marta Glod','75MAGO','Marcel Gommers','75MAGO1','Maciej Gonsior','75MAHO','Marcel Holl','75MAIT','Max Itang','75MAJN','Marcel Janssen','75MAKL','Mark Klaassen','75MAPA','Marcin Pawletko','75MARA','Magdalena Raszkiewicz','75MARC','Marcin Walter','75MARI','Mares v Riswick','75MARO','Mark Rommen','75MASH','Manuel schwachofer','75MASO','Marcel Sohnchen','75MASW','Maciej Swiderski','75MATE','Marcel Testroote','75MAWE','Marian Weber','75MAZA','Marcin Zaleski','75MAZI1','Mateusz Ziemniak','75MEGR','Melanie Greinert','75MEVE','Meta Verhoeven','75MILI','Mike Linders','75MIPO','Michal Posnik','75MISC','Michel Schmitz','75MIST','Michal Stawowiak','75MISZ','Michal Sztencel','75MIVI','Michael Visser','75MOGY','Monika Gyulai','75NAAL','Nathalie Aldenhoven','75NAHE','Nancy Hermans','75NAHO','Nadine Holl','75NEEL','Nelly Tunissen-van Els','75NIAA','Nicole Aarts-Vaessen','75NICR','Niek Cremers','75NISP','Nidia Spranger','75NOJA','Nol Jacobs','75OMER','Omer Ergeldi','75OMLA','Omar Lahyani','75OSGR','Oscar Grabowski','75PABA','Patryk Blama','75PABH','Pascal Bhernards','75PABZ','Pawel Brzostek','75PACR','Patricia Craten','75PADH','Paul Dholen','75PAEH','Pauline Ehrens','75PAGO','Paulo Jorge Gomes','75PAKA','Pawel Kasprowicz','75PAKO','Patrycja Kowalczyk','75PARO','Pascal Rossel','75PEBI','Peter Van der Biezen','75PEDU','Pete Dunn','75PEGE','Peter Geurts','75PEHE','Peter Hegge','75PEJA','Peter Janssen','75PETI','Peter Tissen','75PETO','Petra Toonen','75PIAR','Pinar Arslan','75PIBU','Pierre Buch','75PIPU','Pierre van der Putten','75PRSZ1','Przemyslaw Szczygiel','75PTDL','Peter Dulovic','75PZMA','Przemek Malec','75QUVE','Quincy Vermeulen','75RAGO','Rakesh Gogar','75RAKO','Radoslaw Kozlowski','75RAWE','Randy Weijers','75RAWO','Ralph Wolters','75REBR','Remo Broekmans','75RECL','Remco Claessens','75REWI','Regina Windrath','75RIBE','Rik Te Beest','75RIKE','Rianne Keunen','75RIWI','Richard Winnen','75ROAR','Rojbin Arslan','75ROBO','Rob Bouten','75ROJA','Roswitha Janssen','75ROKE','Roy Kersten','75ROMA','Ronny Malawauw','75ROPE','Ronnie Peters','75ROVA','Roy Van den Bruggen','75ROZE','Robert Zegers','75RUJA','Ruud Janssen','75SAKO','Samantha Kolkman','75SAMA','Samantha Massen','75SAVI','Sandor Virag','75SAYI','Salih Yildiz','75SHDJ','Sharmila Djasai','75SHRO','Shirley Rootbeen','75SIMA','Simona Mauriello1','75SJWI','Sjaak Willems','75SLNO','Slawomir Nowak','75STDO','Stijn van de Donk','75STH1','Stefan Herforth','75STHY','Stuart Hyslop','75STSC','Stefan Schimdt','75SVNI','Sven Nilssen','75SZTO','Szabolcs Torok','75SZWA','Szymon Warwas','75THEA','Theo Jansen','75THJA','Theo Jacobs','75THWI','THEA WILLEMSSEN','75TOFI','Tomasz Filipek','75TOKU','Tomas Kuklis','75TOVE','Toos Verstraelen','75TOWI','Tomasz Wisniewski','75TUTA','Tugba Tavsan','75VETO','Veselin Toshkov','75WIJA','Will Janssen','75WIJS','Willy Jacobs','75WIKE','Wilfried Kempken','75XETR','Xerox Training 1','75XETR1','Xerox Training 2','75YOPE','Yordan Penchev','75YUAK','Yusuf Akbult','75YVVE','Yvette Verkooijen','75ZASA','Zakaria Salad','75ZBMI','Zbigniew Mikurda','75ZHPE','Zhivko Penchev','75DALU','Danielle Luijpers','75DAVE','Danielle v.d. Velden','75JUPLE','Justyna Plecner','75MOVE','Moniek Versteegen','75PERU','Petra Rutten','75SIKU','Silvia Kuklinski') USER_NAME,
        case
            when STATUS = 'In Progress' then LOCATION_ID
            else null
        end INPROGRESSLOC,
        case
            when STATUS = 'In Progress' then sysdate - task_date
            else null
        end IDLETIME,
        WORK_ZONE,
        --VARIANCE_CHECK,
        CLIENT_ID MAX_CLIENT,
        LOCATION_ID CTD_LOCATIONS,
        TO_CHAR(TASK_DATE,'YYYY/MM/DD HH24:MI') MIN_DATE
        from V_STOCK_CHECK_TASKS where LIST_ID is not null
)
group by LIST_ID, WORK_ZONE
    )

    LOOP
        DBMS_OUTPUT.PUT_LINE('
            <TR class="hover">
                <TD>'||s.LIST_ID||'</TD>
                <TD class="tooltip">'||s.USER_ID||'<span class="tooltiptext">'||s.USER_NAME||' on location '||s.INPROGRESSLOC||' for<br>'
                ||SUBSTR(TO_CHAR(s.IDLETIME,'HH24:MI:SS'),9,2)|| 'hrs '
                ||SUBSTR(TO_CHAR(s.IDLETIME,'HH24:MI:SS'),12,2)|| 'min '
                ||SUBSTR(TO_CHAR(s.IDLETIME,'HH24:MI:SS'),15,2)|| 'sec '
                ||'</span></TD>
                <TD class="hide-responsive textcenter">'||s.WORK_ZONE||'</TD>
                <TD class="textcenter">'||s.MAX_CLIENT||'</TD>
                <TD class="textcenter">'||s.CTD_LOCATIONS||'</TD>
                <TD class="textcenter">'||s.MIN_DATE||'</TD>
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
        <TD class="footertext textright" width="80%">created using Report-script:   <font style="font-style:italic">"Dashboard HTML (1.0)"</font></TD>
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