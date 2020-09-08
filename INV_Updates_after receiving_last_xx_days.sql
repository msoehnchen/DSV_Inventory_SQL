select * from
(
    select
    i.CODE,
    i.FROM_LOC_ID,
    i.TO_LOC_ID,
    i.FINAL_LOC_ID,
    i.CLIENT_ID,
    i.SKU_ID,
    i.CONFIG_ID,
    i.PALLET_CONFIG,
    i.TAG_ID,
    i.CONDITION_ID,
    TO_CHAR(i.DSTAMP, 'DD-MON-YYYY HH24:MI:SS') DATESTAMP,
    to_number(substr(i.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) XLS_DATE,
    i.USER_ID,
    i.UPDATE_QTY,
    i.ORIGINAL_QTY, 
    i.NOTES
    from v_inventory_transaction i
    where
        (
            (i.code = 'Adjustment')
            OR (i.code like ('%Update'))
            OR (i.code = 'Stock Check' and i.from_loc_id like ('INB%'))
        )
        and i.dstamp > Sysdate - 32 -- last 32 days
        and i.user_id <> 'Mvtcdae'
) upd
left JOIN
(
    select
--    i.CODE,
--    i.CLIENT_ID,
--    i.SKU_ID,
    i.CONFIG_ID,
    i.PALLET_CONFIG,
    i.TAG_ID,
    TO_CHAR(i.DSTAMP, 'DD-MON-YYYY HH24:MI:SS') RECEIVED_ON,
    to_number(substr(i.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) RECEIVED_ON_XLS,
    i.USER_ID RECEIVED_BY

    from v_inventory_transaction i
    where i.code = 'Receipt'
 
) rec
on upd.TAG_ID = rec.TAG_ID
left JOIN
(
    select USER_ID,USER_NAME from (
        select decode(rownum,1,'72ADNO',2,'72DABR',3,'72DAZA',4,'72DONA',5,'72ERZW',6,'72IVZH',7,'72JARO',8,'72JOVE',9,'72MIM1',10,'72NEDA',11,'72NIHE',12,'72RAZA',13,'75ADAD',14,'75ADDO',15,'75AGJA',16,'75AHBO',17,'75ALKU',18,'75ALLA',19,'75ALMA',20,'75ALNA',21,'75ANBA',22,'75ANCI',23,'75ANGG',24,'75ANHY',25,'75ANIW',26,'75ANKA',27,'75ANKR',28,'75ANKU',29,'75ANPE',30,'75ANPR',31,'75ANSC',32,'75ANTA',33,'75ANVZ',34,'75ARCH',35,'75BAMA',36,'75BAWO',37,'75BAZI',38,'75BOBR',39,'75BOMI',40,'75CACO',41,'75CALO',42,'75CEKA',43,'75CHFL',44,'75CHWE',45,'75CIHE',46,'75COEL',47,'75COHE',48,'75CUVE',49,'75DABA',50,'75DAHR',51,'75DAKO',52,'75DAKU',53,'75DARA',54,'75DASA',55,'75DEIL',56,'75DERE',57,'75DIL1',58,'75DMSM',59,'75DOST',60,'75DOTO',61,'75DRSW',62,'75DSTA',63,'75EDDO',64,'75EDDU',65,'75EDWE',66,'75EDWI',67,'75ELHE',68,'75EMBE',69,'75EMMC',70,'75EMPA',71,'75ERBU',72,'75ETPE',73,'75FEBR',74,'75FIMO',75,'75FLIS',76,'75FRST',77,'75GEKO',78,'75GICL',79,'75GIHO',80,'75GIMO',81,'75GIUP',82,'75GIWI',83,'75GLRA',84,'75GRGA',85,'75GRKE',86,'75GRKO',87,'75GRSM',88,'75GUBE',89,'75HABO',90,'75HAHE',91,'75HASC',92,'75HASE',93,'75HAWE',94,'75HEHE',95,'75HELE',96,'75HEPO',97,'75HOTA',98,'75IGWI',99,'75INGL',100,'75IRHE',101,'75IVYA',102,'75IWTO',103,'75JABU',104,'75JACH',105,'75JADR',106,'75JAHE',107,'75JAJA',108,'75JAKE',109,'75JAST',110,'75JEJU',111,'75JIVE',112,'75JODA',113,'75JOLE',114,'75JOOT',115,'75JOST',116,'75JOWI',117,'75JUMA',118,'75JUNC',119,'75JUPL',120,'75KABO',121,'75KAPE',122,'75KARA',123,'75KAST',124,'75KEMA',125,'75KHJE',126,'75KIBA1',127,'75KIHE',128,'75KLHA',129,'75KLKA',130,'75KMKM',131,'75KOLI',132,'75KOPU',133,'75KOTO',134,'75KRBL',135,'75KRZD',136,'75LABE',137,'75LEGR',138,'75LEMC',139,'75LEPE',140,'75LERU',141,'75LINE',142,'75LITE',143,'75LOAL',144,'75LOPL',145,'75LUMI',146,'75LUSC',147,'75MAAB',148,'75MABE',149,'75MAG1',150,'75MAGL',151,'75MAGO',152,'75MAGO1',153,'75MAHO',154,'75MAIT',155,'75MAJN',156,'75MAKL',157,'75MAPA',158,'75MARA',159,'75MARC',160,'75MARI',161,'75MARO',162,'75MASH',163,'75MASO',164,'75MASW',165,'75MATE',166,'75MAWE',167,'75MAZA',168,'75MAZI1',169,'75MEGR',170,'75MEVE',171,'75MILI',172,'75MIPO',173,'75MISC',174,'75MIST',175,'75MISZ',176,'75MIVI',177,'75MOGY',178,'75MOTA',179,'75NAAL',180,'75NAHE',181,'75NAHO',182,'75NEEL',183,'75NIAA',184,'75NICR',185,'75NISP',186,'75NOBA',187,'75NOJA',188,'75OMER',189,'75OMLA',190,'75OSGR',191,'75PABA',192,'75PABH',193,'75PABZ',194,'75PACR',195,'75PADH',196,'75PAEH',197,'75PAGO',198,'75PAKA',199,'75PAKO',200,'75PARO',201,'75PEBI',202,'75PEDU',203,'75PEGE',204,'75PEHE',205,'75PEJA',206,'75PETI',207,'75PETO',208,'75PIAR',209,'75PIBU',210,'75PIPU',211,'75PRMA',212,'75PRSZ1',213,'75PTDL',214,'75PZMA',215,'75QUVE',216,'75RAGO',217,'75RAKO',218,'75RAWE',219,'75RAWO',220,'75REBR',221,'75RECL',222,'75REWI',223,'75RIBE',224,'75RIKE',225,'75RIWI',226,'75ROAR',227,'75ROBO',228,'75ROJA',229,'75ROKE',230,'75ROMA',231,'75ROPE',232,'75ROVA',233,'75ROWO',234,'75ROZE',235,'75RUJA',236,'75SAMA',237,'75SAVI',238,'75SAYI',239,'75SHDJ',240,'75SHRO',241,'75SIMA',242,'75SJWI',243,'75SLNO',244,'75STDO',245,'75STH1',246,'75STHY',247,'75STSC',248,'75SVNI',249,'75SZTO',250,'75SZWA',251,'75THEA',252,'75THJA',253,'75THWI',254,'75TOFI',255,'75TOKU',256,'75TOVE',257,'75TOWI',258,'75TUTA',259,'75VETO',260,'75WIJA',261,'75WIJS',262,'75WIKE',263,'75XETR',264,'75XETR1',265,'75YOPE',266,'75YUAK',267,'75YVVE',268,'75ZASA',269,'75ZBMI',270,'75ZHPE') as USER_ID,
               decode(rownum,1,'Adrian Nowak',2,'Daniel Brodawski for NLVNR01DV',3,'Daniel Zapotoczny',4,'Dominik Nawlicki for NLVNR01DV',5,'Erica Zwamen',6,'Ivanov Zhivko',7,'Jake Rongen for NLVENR01DV',8,'Joey van ECK for NLVNR01DV',9,'Michel Malas for NLVNR01DV',10,'Nel Danen',11,'Nikki Hendrickx',12,'Rafal Zalewski for NLVNR01DV',13,'Adam Adamek',14,'Adam Dobrynski',15,'Agnieszka Jankowska',16,'Ahmed Boghrissi',17,'Alicia Kuijer',18,'Aleksandra Laskowska',19,'Albert van der Mark',20,'Aleksandra Nawrocka',21,'Andrzej Barczyk',22,'Aneta Cislo',23,'Angelique de Groote',24,'Anna Hydzik',25,'Andrzej Iwanowski',26,'Anna Kapuscinska',27,'Angelo Kraus',28,'Andrea Kutsch',29,'Andra Peneoas',30,'Anetta Przybylska',31,'Andre Schlogl',32,'Anna Tanistra-Biber',33,'Anita van Zanten',34,'Artur Chrzaszcz',35,'Bartozs Mackowiak',36,'Bartosz Wolowski',37,'Bartosz Zielinski',38,'Bokretsien Brhane',39,'Bob van Mil',40,'Catia Costa',41,'Carlos Lopes',42,'Cemal Kaya',43,'Christofer Folkesson',44,'Chris vd Weem',45,'Cindy Hendriks-Emonts',46,'Connie Elsenbruch',47,'Corina Hermans',48,'Customs Venray',49,'Dagmara Baczkowska',50,'David Hermsen',51,'Daniel Korpal',52,'Dawid Kuc',53,'Dana Raytzig',54,'Daniel Salajczyk',55,'Denitsa Ilieva',56,'Glory VAL',57,'Diana Lutger',58,'Dmitrijs Smirnovs',59,'Dolinda Stoks',60,'Dominika Tomaszewska for NLVNR01DV',61,'Dorota Siwak',62,'Donny Staphorst',63,'Edwin Dollenkamp',64,'Edyta Dukielska',65,'Ed van Wegberg',66,'Eduard Wiebe',67,'Elles Hendriks',68,'Emil Beelen',69,'Emmy Cornelissen',70,'Emilia Pawlewska',71,'Ernest Buddiger',72,'Etin Petrochi',73,'Federico Brando',74,'Filip Moczarski',75,'Florin Istrate',76,'Fred Stevens',77,'Gergely Kovacs',78,'Gillian Claessens',79,'Gideon van Houten',80,'Girmay Mokenen',81,'Gints Upenieks',82,'GIOVANNI WIJNEN',83,'Glenn Ratcliff',84,'Grzegorz Gawe?',85,'Grzegorz Kedzia',86,'Gratsiela Koseva',87,'Grzegorz Smalira',88,'Guus Beekhof',89,'Hai Bos',90,'Harry Hendriks',91,'Hans Schreurs',92,'Glory VAL',93,'Hans Westheim',94,'Henrie Hendriks-Jacobs',95,'Herman Lemmens',96,'Herman Poulissen',97,'Hosam Tawakalna',98,'Igor Willer',99,'UNKNOWN',100,'Iris Hermsen',101,'Ivaylo Yankov',102,'Iwona Torzewska',103,'Janin',104,'Jacky Hendriks',105,'Janusz Draszewski',106,'Jan Hendriks',107,'Jakub Jakubowski',108,'Jaan Keijmes',109,'Jack Stelte',110,'Jerryl Juliana',111,'Jim van Eijk',112,'Joanna Dabek',113,'Joao Lemos',114,'Joop van Otterdijk',115,'Joachim Stucki',116,'Joyce Wilms',117,'Juozas Markevicius',118,'Juan Antonio Nchamba',119,'Justyna Plecner',120,'Katarzyna Borowiak',121,'Karolis Petkunas',122,'Kamil Rams',123,'Kamil Staporek',124,'Kevin Maassen',125,'Khaled Jelali',126,'Kinga Barzowska',127,'Kim Hennesen',128,'Klaus Dieter Haag',129,'Klaus Kazmierczak',130,'Kamil Kaminski',131,'Koen van der Linden',132,'Koos Putker',133,'Konrad Tomaszewski',134,'Krysztof Blaszczuk',135,'Krystian Zdrokowski',136,'Laszlo Berecz',137,'Leon Gramser',138,'Lenhard Mclarty',139,'Glory VAL',140,'Lenka Rutten',141,'Lian Nellissen',142,'Lia Tebarts',143,'Loris Alfieri',144,'Lyobomir Peleev',145,'Lukasz Miszewski',146,'Ludwik Scibisz',147,'Mana Abraham',148,'Max Beterams',149,'Magdalena Golke',150,'Marta Glod',151,'Marcel Gommers',152,'Maciej Gonsior',153,'Marcel Holl',154,'Max Itang',155,'Marcel Janssen',156,'Mark Klaassen',157,'Marcin Pawletko',158,'Magdalena Raszkiewicz',159,'Marcin Walter',160,'Mares v Riswick',161,'Mark Rommen',162,'Manuel schwachofer',163,'Marcel Sohnchen',164,'Maciej Swiderski',165,'Marcel Testroote',166,'Glory VAL Marian Weber',167,'Marcin Zaleski',168,'Mateusz Ziemniak',169,'Melanie Greinert',170,'Meta Verhoeven',171,'Mike Linders',172,'Michal Posnik',173,'Michel Schmitz',174,'Michal Stawowiak',175,'Michal Sztencel',176,'Michael Visser',177,'Monika Gyulai',178,'Mohamed Tawakalna',179,'Nathalie Aldenhoven',180,'Nancy Hermans',181,'Nadine Holl',182,'Nelly Tunissen-van Els',183,'Nicole Aarts-Vaessen',184,'Niek Cremers',185,'Nidia Spranger',186,'Norbert Baginski',187,'Nol Jacobs',188,'Omer Ergeldi',189,'Omar Lahyani',190,'Oscar Grabowski',191,'Patryk Blama',192,'Pascal Bhernards',193,'Pawel Brzostek',194,'Patricia Craten',195,'Paul Dholen',196,'Pauline Ehrens',197,'Paulo Jorge Gomes',198,'Pawel Kasprowicz',199,'Patrycja Kowalczyk',200,'Pascal Rossel',201,'Peter Van der Biezen',202,'Pete Dunn',203,'Peter Geurts',204,'75 Peter Hegge',205,'Peter Janssen',206,'Peter Tissen',207,'Petra Toonen',208,'Pinar Arslan',209,'Pierre Buch',210,'Pierre van der Putten',211,'Presilia Macku',212,'Przemyslaw Szczygiel',213,'Peter Dulovic',214,'Przemek Malec',215,'Quincy Vermeulen',216,'Rakesh Gogar',217,'Radoslaw Kozlowski',218,'Randy Weijers',219,'Ralph Wolters',220,'Remo Broekmans',221,'Remco Claessens',222,'Regina Windrath',223,'Rik Te Beest',224,'Rianne Keunen',225,'Richard Winnen',226,'Rojbin Arslan',227,'Rob Bouten',228,'Roswitha Janssen',229,'Roy Kersten',230,'Ronny Malawauw',231,'Ronnie Peters',232,'Roy Van den Bruggen',233,'Roger Wolters',234,'Robert Zegers',235,'Ruud Janssen',236,'Samantha Massen',237,'Sandor Virag',238,'Salih Yildiz',239,'Sharmila Djasai',240,'Shirley Rootbeen',241,'Simona Mauriello1',242,'Sjaak Willems',243,'Slawomir Nowak',244,'Stijn van de Donk',245,'Stefan Herforth',246,'Stuart Hyslop',247,'Stefan Schimdt',248,'Sven Nilssen',249,'Szabolcs Torok',250,'Szymon Warwas',251,'Theo Jansen',252,'Theo Jacobs',253,'THEA WILLEMSSEN',254,'Tomasz Filipek',255,'Tomas Kuklis',256,'Toos Verstraelen',257,'Tomasz Wisniewski',258,'Tugba Tavsan',259,'Veselin Toshkov',260,'Glory VAL',261,'Willy Jacobs',262,'Wilfried Kempken',263,'Xerox Training 1',264,'Xerox Training 2',265,'Yordan Penchev',266,'Yusuf Akbult',267,'Yvette Verkooijen',268,'Zakaria Salad',269,'Zbigniew Mikurda',270,'Zhivko Penchev') as USER_NAME
          from dual
        connect by level <= 270
    ) d
) d
on rec.RECEIVED_BY = d.USER_ID