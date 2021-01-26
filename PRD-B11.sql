select
LIST_ID, max(USER_ID) USER_ID, max(USER_NAME) USER_NAME, max(INPROGRESSLOC) INPROGRESSLOC, WORK_ZONE, max(MAX_CLIENT) MAX_CLIENT, count(distinct CTD_LOCATIONS) CTD_LOCATIONS, min(MIN_DATE) MIN_DATE
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
        WORK_ZONE,
        --VARIANCE_CHECK,
        CLIENT_ID MAX_CLIENT,
        LOCATION_ID CTD_LOCATIONS,
        TO_CHAR(TASK_DATE,'YYYY/MM/DD HH24:MI') MIN_DATE
        from V_STOCK_CHECK_TASKS where LIST_ID is not null
)
group by LIST_ID, WORK_ZONE