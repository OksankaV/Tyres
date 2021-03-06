PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE TyreFamily (
id INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
family_title TEXT(50) NOT NULL ,
brand_title TEXT(50) NOT NULL  REFERENCES TyreBrand (title),
description TEXT(200),
season TEXT(20) NOT NULL ,
image TEXT(100),
UNIQUE (family_title, brand_title)
);
INSERT INTO "TyreFamily" VALUES(1,'WR A3','Nokian','Шини Nokian WR A3 є оптимальним варіантом для надійного автомобіля, в якому особлива увага приділяється точності та чутливості керування при керуванні на підвищених швидкостях.','W','nokian_WR_A3.png');
INSERT INTO "TyreFamily" VALUES(2,'Hakkapeliitta 7','Nokian','Nokian Hakkapeliitta 7 – абсолютно нова шипована шина для суворих умов, яка поєднує незаперечні зимові властивості і надзвичайну комфортабельність.','W','nokian_Hakkapeliitta_7.png');
INSERT INTO "TyreFamily" VALUES(3,'Hakka Blue','Nokian','Високопродуктивні літні шини Nokian Hakka Blue майстерно долають будь-які погодні умови мінливого літа.','S','nokian_Hakka_Blue.png');
INSERT INTO "TyreFamily" VALUES(4,'Nordman SX','Nokian','Nokian Nordman SX – міцна та економічна шина для літа з індексом швидкості Т (190 км/год), яка підходить для сімейних автомобілів малого і середнього класів.','S','nokian_Nordman_SX.png');
INSERT INTO "TyreFamily" VALUES(5,'B250','Bridgestone','Шини Bridgestone B250 створені як еталон якості й технічних характеристик літніх шин. Розробляючи шину В250, компанія Bridgestone поставила перед собою високі цілі й досягла поставленої мети.','S','Bridgestone_B250.png');
INSERT INTO "TyreFamily" VALUES(6,'Blizzak LM-22','Bridgestone','Шини Bridgestone Blizzak LM-22 створені для легкових автомобілів, забезпечують на високому рівні показники стійкості й прохідності на дорогах у зимових умовах.','W','Bridgestone_Blizzak_LM-22.png');
INSERT INTO "TyreFamily" VALUES(7,'Dueler H/T 687','Bridgestone','Bridgestone Dueler H/T 687 - всесезонні шини створені для джипів і легкогрузовиків. ','A','Bridgestone_Dueler_H-T_687.png');
INSERT INTO "TyreFamily" VALUES(8,'Blizzak LM18','Bridgestone',NULL,'A','Bridgestone_Blizzak_LM18.png');
INSERT INTO "TyreFamily" VALUES(9,'SP Sport Maxx TT','Dunlop','Dunlop SP Sport Maxx TT - прочные летние шины от компании Dunlop. ','S','Dunlop_SP_Sport_Maxx_TT.png');
INSERT INTO "TyreFamily" VALUES(10,'Grandtrek ST 1','Dunlop','Grandtrek ST 1 - всесезонные спортивные шины премиум-класса. ','A','Dunlop_Grandtrek_ST_1.png');
INSERT INTO "TyreFamily" VALUES(11,'Grandtrek WTM3','Dunlop','Dunlop Grandtrek WTM3 - зимние шины премиум-класса от компании Dunlop.','W','Dunlop_Grandtrek_WTM3.png');
INSERT INTO "TyreFamily" VALUES(12,'Graspic DS-3','Dunlop','Dunlop Graspic DS-3 - нешипованные зимние шины от компании Dunlop.','W','Dunlop_Graspic_DS-3.png');
INSERT INTO "TyreFamily" VALUES(13,'WR A3','Nokian2','Шини Nokian WR A3 є оптимальним варіантом для надійного автомобіля, в якому особлива увага приділяється точності та чутливості керування при керуванні на підвищених швидкостях.','W','nokian_WR_A3.png');
INSERT INTO "TyreFamily" VALUES(14,'Hakkapeliitta 7','Nokian2','Nokian Hakkapeliitta 7 – абсолютно нова шипована шина для суворих умов, яка поєднує незаперечні зимові властивості і надзвичайну комфортабельність.','W','nokian_Hakkapeliitta_7.png');
INSERT INTO "TyreFamily" VALUES(15,'Hakka Blue','Nokian2','Високопродуктивні літні шини Nokian Hakka Blue майстерно долають будь-які погодні умови мінливого літа.','S','nokian_Hakka_Blue.png');
INSERT INTO "TyreFamily" VALUES(16,'Nordman SX','Nokian2','Nokian Nordman SX – міцна та економічна шина для літа з індексом швидкості Т (190 км/год), яка підходить для сімейних автомобілів малого і середнього класів.','S','nokian_Nordman_SX.png');
INSERT INTO "TyreFamily" VALUES(17,'B250','Bridgestone2','Шини Bridgestone B250 створені як еталон якості й технічних характеристик літніх шин. Розробляючи шину В250, компанія Bridgestone поставила перед собою високі цілі й досягла поставленої мети.','S','Bridgestone_B250.png');
INSERT INTO "TyreFamily" VALUES(18,'Blizzak LM-22','Bridgestone2','Шини Bridgestone Blizzak LM-22 створені для легкових автомобілів, забезпечують на високому рівні показники стійкості й прохідності на дорогах у зимових умовах.','W','Bridgestone_Blizzak_LM-22.png');
INSERT INTO "TyreFamily" VALUES(19,'Dueler H/T 687','Bridgestone2','Bridgestone Dueler H/T 687 - всесезонні шини створені для джипів і легкогрузовиків. ','A','Bridgestone_Dueler_H-T_687.png');
INSERT INTO "TyreFamily" VALUES(20,'Blizzak LM18','Bridgestone2',NULL,'A','Bridgestone_Blizzak_LM18.png');
INSERT INTO "TyreFamily" VALUES(21,'SP Sport Maxx TT','Dunlop2','Dunlop SP Sport Maxx TT - прочные летние шины от компании Dunlop. ','S','Dunlop_SP_Sport_Maxx_TT.png');
INSERT INTO "TyreFamily" VALUES(22,'Grandtrek ST 1','Dunlop2','Grandtrek ST 1 - всесезонные спортивные шины премиум-класса. ','A','Dunlop_Grandtrek_ST_1.png');
INSERT INTO "TyreFamily" VALUES(23,'Grandtrek WTM3','Dunlop2','Dunlop Grandtrek WTM3 - зимние шины премиум-класса от компании Dunlop.','W','Dunlop_Grandtrek_WTM3.png');
INSERT INTO "TyreFamily" VALUES(24,'Graspic DS-3','Dunlop2','Dunlop Graspic DS-3 - нешипованные зимние шины от компании Dunlop.','W','Dunlop_Graspic_DS-3.png');
INSERT INTO "TyreFamily" VALUES(25,'WR A3','Nokian3','Шини Nokian WR A3 є оптимальним варіантом для надійного автомобіля, в якому особлива увага приділяється точності та чутливості керування при керуванні на підвищених швидкостях.','W','nokian_WR_A3.png');
INSERT INTO "TyreFamily" VALUES(26,'Hakkapeliitta 7','Nokian3','Nokian Hakkapeliitta 7 – абсолютно нова шипована шина для суворих умов, яка поєднує незаперечні зимові властивості і надзвичайну комфортабельність.','W','nokian_Hakkapeliitta_7.png');
INSERT INTO "TyreFamily" VALUES(27,'Hakka Blue','Nokian3','Високопродуктивні літні шини Nokian Hakka Blue майстерно долають будь-які погодні умови мінливого літа.','S','nokian_Hakka_Blue.png');
INSERT INTO "TyreFamily" VALUES(28,'Nordman SX','Nokian3','Nokian Nordman SX – міцна та економічна шина для літа з індексом швидкості Т (190 км/год), яка підходить для сімейних автомобілів малого і середнього класів.','S','nokian_Nordman_SX.png');
INSERT INTO "TyreFamily" VALUES(29,'B250','Bridgestone3','Шини Bridgestone B250 створені як еталон якості й технічних характеристик літніх шин. Розробляючи шину В250, компанія Bridgestone поставила перед собою високі цілі й досягла поставленої мети.','S','Bridgestone_B250.png');
INSERT INTO "TyreFamily" VALUES(30,'Blizzak LM-22','Bridgestone3','Шини Bridgestone Blizzak LM-22 створені для легкових автомобілів, забезпечують на високому рівні показники стійкості й прохідності на дорогах у зимових умовах.','W','Bridgestone_Blizzak_LM-22.png');
INSERT INTO "TyreFamily" VALUES(31,'Dueler H/T 687','Bridgestone3','Bridgestone Dueler H/T 687 - всесезонні шини створені для джипів і легкогрузовиків. ','A','Bridgestone_Dueler_H-T_687.png');
INSERT INTO "TyreFamily" VALUES(32,'Blizzak LM18','Bridgestone3',NULL,'A','Bridgestone_Blizzak_LM18.png');
INSERT INTO "TyreFamily" VALUES(33,'SP Sport Maxx TT','Dunlop3','Dunlop SP Sport Maxx TT - прочные летние шины от компании Dunlop. ','S','Dunlop_SP_Sport_Maxx_TT.png');
INSERT INTO "TyreFamily" VALUES(34,'Grandt ST 11','Dunlop3','Grandtrek ST 1 - всесезонные спортивные шины премиум-класса. ','A','Dunlop_Grandtrek_ST_1.png');
INSERT INTO "TyreFamily" VALUES(35,'Grandt WTM3','Dunlop3','Dunlop Grandtrek WTM3 - зимние шины премиум-класса от компании Dunlop.','W','Dunlop_Grandtrek_WTM3.png');
INSERT INTO "TyreFamily" VALUES(36,'Gras DS-3','Dunlop3','Dunlop Graspic DS-3 - нешипованные зимние шины от компании Dunlop.','W','Dunlop_Graspic_DS-3.png');
CREATE TABLE TyreBrand (
title TEXT(50) NOT NULL  PRIMARY KEY,
description TEXT(200),
site TEXT(50),
logotype TEXT(100)
);
INSERT INTO "TyreBrand" VALUES('Dunlop','В настоящее время компания Dunlop занимает 5-е место в мире по объему производства шин. Dunlop заключила контракты на поставку шин с 33-мя автогигантами.','http://dunlopua.com','dunlop.png');
INSERT INTO "TyreBrand" VALUES('Bridgestone','Компанія Bridgestone Corporation була заснована 1 березня 1931 року. ЇЇ засновником став Шоджіро Ішібаші (1889-1976).','http://bridgestoneua.com','bridgestone.jpg');
INSERT INTO "TyreBrand" VALUES('Nokian','Nokian Tyres — фінський концерн, що розробляє та виготовляє шини для легкових автомобілів, вантажного транспорту та індустріальної техніки.','http://www.nokiantyres.ua','nokian.gif');
INSERT INTO "TyreBrand" VALUES('Dunlop2','В настоящее время компания Dunlop занимает 5-е место в мире по объему производства шин. Dunlop заключила контракты на поставку шин с 33-мя автогигантами.','http://dunlopua.com','dunlop.png');
INSERT INTO "TyreBrand" VALUES('Bridgestone2','Компанія Bridgestone Corporation була заснована 1 березня 1931 року. ЇЇ засновником став Шоджіро Ішібаші (1889-1976).','http://bridgestoneua.com','bridgestone.jpg');
INSERT INTO "TyreBrand" VALUES('Nokian2','Nokian Tyres — фінський концерн, що розробляє та виготовляє шини для легкових автомобілів, вантажного транспорту та індустріальної техніки.','http://www.nokiantyres.ua','nokian.gif');
INSERT INTO "TyreBrand" VALUES('Dunlop3','В настоящее время компания Dunlop занимает 5-е место в мире по объему производства шин. Dunlop заключила контракты на поставку шин с 33-мя автогигантами.','http://dunlopua.com','dunlop.png');
INSERT INTO "TyreBrand" VALUES('Bridgestone3','Компанія Bridgestone Corporation була заснована 1 березня 1931 року. ЇЇ засновником став Шоджіро Ішібаші (1889-1976).','http://bridgestoneua.com','bridgestone.jpg');
INSERT INTO "TyreBrand" VALUES('Nokian3','Nokian Tyres — фінський концерн, що розробляє та виготовляє шини для легкових автомобілів, вантажного транспорту та індустріальної техніки.','http://www.nokiantyres.ua','nokian.gif');
CREATE TABLE TyreProvider (
id INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
title TEXT(50) NOT NULL
);
INSERT INTO "TyreProvider" VALUES(1,'Oksanka');
INSERT INTO "TyreProvider" VALUES(2,'Yulia');
INSERT INTO "TyreProvider" VALUES(3,'Yura');
CREATE TABLE TyreModel (
id INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
family_id INTEGER NOT NULL  REFERENCES TyreFamily (id),
canonical_size TEXT(50) NOT NULL ,
width INTEGER NOT NULL ,
height INTEGER NOT NULL ,
rim_diameter INTEGER NOT NULL ,
load_index TEXT(20),
speed_symbol TEXT(20),
purpose TEXT(30),
extra_load TEXT(20)
);
INSERT INTO "TyreModel" VALUES(1,1,'195/50 R 15 86 H XL',195,50,15,'86','H',NULL,'XL');
INSERT INTO "TyreModel" VALUES(2,1,'205/50 R 16 91 H XL',205,50,16,'91','H',NULL,'XL');
INSERT INTO "TyreModel" VALUES(3,1,'215/45 R 17 91 V XL',215,45,17,'91','V',NULL,'XL');
INSERT INTO "TyreModel" VALUES(4,2,'175/70 R 13 82 T',175,70,13,'82','T',NULL,NULL);
INSERT INTO "TyreModel" VALUES(5,2,'235/40 R 18 95 T XL',235,40,18,'95','T',NULL,'XL');
INSERT INTO "TyreModel" VALUES(6,3,'195/50 R 15 86 V XL',195,50,15,'86','V',NULL,'XL');
INSERT INTO "TyreModel" VALUES(7,3,'205/50 R 16 91 V XL',205,50,16,'91','V',NULL,'XL');
INSERT INTO "TyreModel" VALUES(8,3,'225/50 R 17 98 W XL',215,50,17,'98','W',NULL,'XL');
INSERT INTO "TyreModel" VALUES(9,4,'175/70 R 14 84 T',175,70,14,'84','T',NULL,NULL);
INSERT INTO "TyreModel" VALUES(10,4,'225/45 R 17 94 V XL',225,45,17,'94','V',NULL,'XL');
INSERT INTO "TyreModel" VALUES(11,5,'175/70 R 13 82',175,70,13,'82',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(12,6,'215/45 R 18 93 XL',215,45,18,'93',NULL,NULL,'XL');
INSERT INTO "TyreModel" VALUES(13,6,'235/50 R 17 96',235,50,17,'96',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(14,7,'225/70 R 16 102',225,70,16,'102',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(15,7,'225/65 R 17 101',225,65,17,'101',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(16,8,'225/60 R 16 98',225,60,16,'98',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(17,9,'205/50 R 17 93 Y',205,50,17,'93','Y',NULL,NULL);
INSERT INTO "TyreModel" VALUES(18,9,'225/45 R 18 95 W',225,45,18,'95','W',NULL,NULL);
INSERT INTO "TyreModel" VALUES(19,10,'205/70 R 15 95 S',205,70,15,'95','S',NULL,NULL);
INSERT INTO "TyreModel" VALUES(20,11,'235/65 R 18 109 H',235,65,18,'109','H',NULL,NULL);
INSERT INTO "TyreModel" VALUES(21,11,'255/50 R 19 107 V',255,50,19,'107','V',NULL,NULL);
INSERT INTO "TyreModel" VALUES(22,12,'175/70 R 14 84 Q',235,65,18,'109','H',NULL,NULL);
INSERT INTO "TyreModel" VALUES(23,12,'215/60 R 16 99 Q XL',215,60,16,'99','Q',NULL,'XL');
INSERT INTO "TyreModel" VALUES(24,13,'175/70 R 13 82 T',175,70,13,'82','T',NULL,NULL);
INSERT INTO "TyreModel" VALUES(25,14,'235/40 R 18 95 T XL',235,40,18,'95','T',NULL,'XL');
INSERT INTO "TyreModel" VALUES(26,15,'195/50 R 15 86 V XL',195,50,15,'86','V',NULL,'XL');
INSERT INTO "TyreModel" VALUES(27,16,'205/50 R 16 91 V XL',205,50,16,'91','V',NULL,'XL');
INSERT INTO "TyreModel" VALUES(28,17,'225/50 R 17 98 W XL',215,50,17,'98','W',NULL,'XL');
INSERT INTO "TyreModel" VALUES(29,18,'175/70 R 14 84 T',175,70,14,'84','T',NULL,NULL);
INSERT INTO "TyreModel" VALUES(30,19,'225/45 R 17 94 V XL',225,45,17,'94','V',NULL,'XL');
INSERT INTO "TyreModel" VALUES(31,20,'175/70 R 13 82',175,70,13,'82',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(32,21,'215/45 R 18 93 XL',215,45,18,'93',NULL,NULL,'XL');
INSERT INTO "TyreModel" VALUES(33,22,'235/50 R 17 96',235,50,17,'96',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(34,23,'225/70 R 16 102',225,70,16,'102',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(35,24,'225/65 R 17 101',225,65,17,'101',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(36,25,'225/60 R 16 98',225,60,16,'98',NULL,NULL,NULL);
INSERT INTO "TyreModel" VALUES(37,26,'205/50 R 17 93 Y',205,50,17,'93','Y',NULL,NULL);
INSERT INTO "TyreModel" VALUES(38,27,'225/45 R 18 95 W',225,45,18,'95','W',NULL,NULL);
INSERT INTO "TyreModel" VALUES(39,28,'205/70 R 15 95 S',205,70,15,'95','S',NULL,NULL);
INSERT INTO "TyreModel" VALUES(40,29,'235/65 R 18 109 H',235,65,18,'109','H',NULL,NULL);
INSERT INTO "TyreModel" VALUES(41,30,'255/50 R 19 107 V',255,50,19,'107','V',NULL,NULL);
INSERT INTO "TyreModel" VALUES(42,31,'175/70 R 14 84 Q',235,65,18,'109','H',NULL,NULL);
INSERT INTO "TyreModel" VALUES(43,32,'215/60 R 16 99 Q XL',215,60,16,'99','Q',NULL,'XL');
INSERT INTO "TyreModel" VALUES(44,33,'235/65 R 18 109 H',235,65,18,'109','H',NULL,NULL);
INSERT INTO "TyreModel" VALUES(45,34,'255/50 R 19 107 V',255,50,19,'107','V',NULL,NULL);
INSERT INTO "TyreModel" VALUES(46,35,'175/70 R 14 84 Q',235,65,18,'109','H',NULL,NULL);
INSERT INTO "TyreModel" VALUES(47,36,'215/60 R 16 99 Q XL',215,60,16,'99','Q',NULL,'XL');
CREATE TABLE TyreArticle (
id INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
model_id INTEGER NOT NULL  REFERENCES TyreModel (id),
price REAL(5,2) NOT NULL ,
quantity INTEGER NOT NULL ,
provider_id INTEGER NOT NULL  REFERENCES TyreProvider (id),
production_date TEXT(6) NOT NULL 
);
INSERT INTO "TyreArticle" VALUES(1,1,456.99,33,1,'162012');
INSERT INTO "TyreArticle" VALUES(2,2,786.9,3,2,'142012');
INSERT INTO "TyreArticle" VALUES(3,2,694.99,4,1,'142012');
INSERT INTO "TyreArticle" VALUES(4,2,567.55,76,3,'162012');
INSERT INTO "TyreArticle" VALUES(5,3,684.77,7,3,'152012');
INSERT INTO "TyreArticle" VALUES(6,3,446.0,6,1,'162012');
INSERT INTO "TyreArticle" VALUES(7,4,478.9,23,3,'122012');
INSERT INTO "TyreArticle" VALUES(8,4,421.5,44,2,'112012');
INSERT INTO "TyreArticle" VALUES(9,5,567.25,3,1,'162012');
INSERT INTO "TyreArticle" VALUES(10,6,735.0,6,1,'172012');
INSERT INTO "TyreArticle" VALUES(11,6,698.45,0,2,'192012');
INSERT INTO "TyreArticle" VALUES(12,6,778.0,33,3,'222012');
INSERT INTO "TyreArticle" VALUES(13,7,766.99,36,1,'162012');
INSERT INTO "TyreArticle" VALUES(14,7,786.9,6,2,'142012');
INSERT INTO "TyreArticle" VALUES(15,8,894.99,4,1,'142012');
INSERT INTO "TyreArticle" VALUES(16,9,967.55,17,3,'162012');
INSERT INTO "TyreArticle" VALUES(17,9,984.0,23,2,'152012');
INSERT INTO "TyreArticle" VALUES(18,9,946.7,6,1,'162012');
INSERT INTO "TyreArticle" VALUES(19,10,478.9,23,3,'122012');
INSERT INTO "TyreArticle" VALUES(20,10,421.5,14,2,'112012');
INSERT INTO "TyreArticle" VALUES(21,11,567.25,0,1,'162012');
INSERT INTO "TyreArticle" VALUES(22,11,435.0,6,2,'172012');
INSERT INTO "TyreArticle" VALUES(23,12,698.45,0,2,'192012');
INSERT INTO "TyreArticle" VALUES(24,12,778.0,13,3,'222012');
INSERT INTO "TyreArticle" VALUES(25,13,535.0,6,1,'472011');
INSERT INTO "TyreArticle" VALUES(26,13,698.45,0,2,'192011');
INSERT INTO "TyreArticle" VALUES(27,14,778.0,33,3,'222012');
INSERT INTO "TyreArticle" VALUES(28,15,1266.99,36,1,'162012');
INSERT INTO "TyreArticle" VALUES(29,16,886.9,65,2,'142012');
INSERT INTO "TyreArticle" VALUES(30,16,894.99,4,1,'242012');
INSERT INTO "TyreArticle" VALUES(31,16,867.55,17,3,'162011');
INSERT INTO "TyreArticle" VALUES(32,17,984.0,23,2,'252011');
INSERT INTO "TyreArticle" VALUES(33,17,946.7,6,1,'262011');
INSERT INTO "TyreArticle" VALUES(34,18,478.9,23,3,'122011');
INSERT INTO "TyreArticle" VALUES(35,19,421.5,14,2,'312012');
INSERT INTO "TyreArticle" VALUES(36,19,567.25,0,1,'162011');
INSERT INTO "TyreArticle" VALUES(37,20,435.0,6,1,'172012');
INSERT INTO "TyreArticle" VALUES(38,20,698.45,0,2,'292011'); 
INSERT INTO "TyreArticle" VALUES(39,21,878.0,13,3,'222012'); 
INSERT INTO "TyreArticle" VALUES(40,21,835.0,6,1,'27201');  
INSERT INTO "TyreArticle" VALUES(41,22,498.45,5,2,'192012');
INSERT INTO "TyreArticle" VALUES(42,23,778.0,13,3,'222011');
INSERT INTO "TyreArticle" VALUES(43,23,755.99,18,2,'222012');
INSERT INTO "TyreArticle" VALUES(44,24,567.55,76,2,'162012');
INSERT INTO "TyreArticle" VALUES(45,24,567.55,7,3,'152012');
INSERT INTO "TyreArticle" VALUES(46,25,446.0,6,1,'162012');
INSERT INTO "TyreArticle" VALUES(47,26,478.9,23,3,'122012');
INSERT INTO "TyreArticle" VALUES(48,27,421.5,44,2,'112012');
INSERT INTO "TyreArticle" VALUES(49,27,567.25,3,1,'162012');
INSERT INTO "TyreArticle" VALUES(50,28,735.0,6,1,'172012');
INSERT INTO "TyreArticle" VALUES(51,28,698.45,0,2,'192012');
INSERT INTO "TyreArticle" VALUES(52,29,778.0,33,3,'222012');
INSERT INTO "TyreArticle" VALUES(53,30,766.99,36,1,'162012');
INSERT INTO "TyreArticle" VALUES(54,30,786.9,6,2,'142012');
INSERT INTO "TyreArticle" VALUES(55,31,894.99,4,1,'142012');
INSERT INTO "TyreArticle" VALUES(56,31,967.55,17,3,'162012');
INSERT INTO "TyreArticle" VALUES(57,31,984.0,23,2,'152012');
INSERT INTO "TyreArticle" VALUES(58,32,946.7,6,1,'162012');
INSERT INTO "TyreArticle" VALUES(59,33,478.9,23,3,'122012');
INSERT INTO "TyreArticle" VALUES(60,34,421.5,14,2,'112012');
INSERT INTO "TyreArticle" VALUES(61,34,567.25,0,1,'162012');
INSERT INTO "TyreArticle" VALUES(62,35,435.0,6,2,'172012');
INSERT INTO "TyreArticle" VALUES(63,36,698.45,0,2,'192012');
INSERT INTO "TyreArticle" VALUES(64,37,778.0,13,3,'222012');
INSERT INTO "TyreArticle" VALUES(65,37,535.0,6,1,'472011');
INSERT INTO "TyreArticle" VALUES(66,38,698.45,0,2,'192011');
INSERT INTO "TyreArticle" VALUES(67,38,778.0,33,3,'222012');
INSERT INTO "TyreArticle" VALUES(68,39,1266.99,36,1,'162012');
INSERT INTO "TyreArticle" VALUES(69,39,886.9,65,2,'142012');
INSERT INTO "TyreArticle" VALUES(70,39,894.99,4,3,'242012');
INSERT INTO "TyreArticle" VALUES(71,40,867.55,17,3,'162011');
INSERT INTO "TyreArticle" VALUES(72,40,984.0,23,2,'252011');
INSERT INTO "TyreArticle" VALUES(73,41,946.7,6,1,'262011');
INSERT INTO "TyreArticle" VALUES(74,41,478.9,23,3,'122011');
INSERT INTO "TyreArticle" VALUES(75,41,421.5,14,2,'312012');
INSERT INTO "TyreArticle" VALUES(76,42,567.25,0,1,'162011');
INSERT INTO "TyreArticle" VALUES(77,43,435.0,6,1,'172012');
INSERT INTO "TyreArticle" VALUES(78,44,698.45,0,2,'292011'); 
INSERT INTO "TyreArticle" VALUES(79,44,878.0,13,3,'222012'); 
INSERT INTO "TyreArticle" VALUES(80,45,999.0,6,1,'27201');  
INSERT INTO "TyreArticle" VALUES(81,46,777.0,5,2,'192012');
INSERT INTO "TyreArticle" VALUES(82,47,444.0,13,3,'222011');
INSERT INTO "TyreArticle" VALUES(83,47,444.0,18,2,'222012');

CREATE TABLE Orders (
id INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
name TEXT(100) NOT NULL ,
address TEXT(200) DEFAULT NULL,
email TEXT(100) DEFAULT NULL,
phone TEXT(50) NOT NULL ,
date TEXT(50) NOT NULL ,
status INTEGER NOT NULL 
);
CREATE TABLE OrdersElements (
order_id INTEGER NOT NULL  REFERENCES Orders (id),
article_id INTEGER NOT NULL  REFERENCES TyreArticle (id),
price REAL(2) NOT NULL ,
quantity INTEGER NOT NULL ,
PRIMARY KEY (order_id, article_id)
);
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('TyreFamily',36);
INSERT INTO "sqlite_sequence" VALUES('TyreProvider',3);
INSERT INTO "sqlite_sequence" VALUES('TyreModel',47);
INSERT INTO "sqlite_sequence" VALUES('TyreArticle',83);
COMMIT;
