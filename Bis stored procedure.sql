create database schlussprojekt;  

use schlussprojekt;
--first create tables and then the connection and later the diagram
--Table 1 Kunden(customer) details
create table kunden
	(KID int identity primary key,
	Vorname nvarchar(50),
	Nachname nvarchar(50),
	Email nvarchar(100),
	Telefon nvarchar(20),
	stadt nvarchar(100),
	strasse nvarchar(50),
	PLZ int,
	Istaktiv bit not null default 1);

	--Table 2 liefernaten (Delivery) details
create table Lieferanten
	(LID int identity primary key,
	Name nvarchar(50),
	Ort nvarchar(100),
	EmailId nvarchar(100),
	Telefon nvarchar(20));

--Table 3 Kategorien (categories)
create table Kategorien
	(KID int identity primary key,
	KategorieName nvarchar(100) unique,
	Beschreibung nvarchar(500)
	);



--Table 4  produkte(products)
create table produkte
	(PID int  identity primary key,
	productName nvarchar(100),
	KID int,
	LID int,
	Einzelprice decimal(10,2) check (Einzelprice >0),
	Marke nvarchar(80),
	constraint fk_kid foreign key (KID) references Kategorien(KID),
	constraint fk_lid foreign key (LID) references Lieferanten(LID)
	);

--Table 5 mitarbeiter (Employees)
create table mitarbeiter
	(MID int identity primary key,
	Vorname nvarchar(50),
	Nachname nvarchar(50),
	EmailID nvarchar(50),
	Telefone nvarchar(50),
	Rolle nvarchar(50)
);

--Table 6 Bestellungen (orders)
create table bestellungen 
	(BID int identity primary key,
	KID int,
	MID int,
	Bestelldatum datetime DEFAULT  GETDATE(),
	Status nvarchar(50),
	Lieferadresse nvarchar(500),
	LifereungKosten decimal(10,2),
	SubTotal decimal(12,2),
	MWst decimal(10,2),
	Gesamt decimal(10,2)
	constraint fk_kid1 foreign key(KID) references Kunden(KID),
	constraint fk_mid1 foreign key(MID) references mitarbeiter(MID)
);

 --Table 7  Bestellpositionen (OrderItems)

create table Bestellpositionen
	(BestellpositionID int identity primary key,
	BID int,
	PID int,
	Menge int check(Menge > 0),
	Einzelpreis decimal(10,2) check(Einzelpreis > 0),
	Rabatt DECIMAL(4,2),
	constraint FK_BP_Bestellung foreign key (BID) references Bestellungen(BID),
	constraint FK_BP_Produkt foreign key (PID) references Produkte(PID)
	);
--Table 8 zahlung
--start with payments from tomorrow
--zahlungasrt can be paypal,klarna, bankkonto,karte, emi,

create table zahlung
	(ZID int identity primary key,
	BID int not  null,
	zahlungdatum datetime DEFAULT  GETDATE(),
	Betrag DECIMAL(12,2) NOT NULL CHECk(Betrag>0),
	Zahlungsart nvarchar(50) NOT NULL,
	constraint fk_zhalung_bestellung foreign key(BID) references bestellungen(BID)
	);


--Table 9 review
--start with review from monday
create table  bewertungen
	 (BewID int,
	 BID int, --bestellung id
	 PID int, --product id
	 KID int, --customer id
	 Beschreibung nvarchar(1000),
	 Erstelltam date DEFAULT getdate(),
	 constraint fk_bew_BID foreign key(BID) references bestellungen(BID),
	 constraint fk_bew_PID foreign key(PID) references produkte(PID),
	 constraint fk_bew_KID foreign key(KID) references kunden(KID)
);


--Table 10 --product tags, every product has it's own unique tag id
create table Tags (
    TagID int identity primary key,
    TagName nvarchar(100) not null  unique
);


--Table 11 product tags : many to many relationship

create table produkttags ( ---created m:n reationship
    ProduktID int not  null,
    TagID int not  null,
    primary key (ProduktID, TagID),-- composite primary key
    constraint FK_PT_Produkt foreign key (ProduktID) references Produkte(PID),
    constraint FK_PT_Tag foreign key (TagID) references Tags(TagID)
)
--TABLE 12 DELIVERY DETAILS

CREATE TABLE dbo.Lieferungen (
    LieferungID INT IDENTITY PRIMARY KEY,
    BestellungID INT NOT NULL,          -- FK to Bestellungen
    LieferantID INT NOT NULL,           -- FK to Lieferanten
    LieferDatum DATETIME2 NOT NULL DEFAULT GETDATE(),
    TrackingNumber NVARCHAR(100) NULL,
    Versandart NVARCHAR(100) NULL,      -- e.g. DHL, UPS, Spedition
    LieferStatus NVARCHAR(50) NOT NULL DEFAULT 'Versendet', -- Versendet, Unterwegs, Zugestellt, Rücksendung
    Lieferkosten DECIMAL(12,2) NULL CHECK (Lieferkosten >= 0),
    Empfangen BIT NULL,                 -- Has the customer confirmed receipt?
    Bemerkung NVARCHAR(400) NULL,
    ErstelltAm DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Lieferungen_Bestellung FOREIGN KEY (BestellungID) REFERENCES dbo.Bestellungen(BID),
    CONSTRAINT FK_Lieferungen_Lieferant FOREIGN KEY (LieferantID) REFERENCES dbo.Lieferanten(LID)
);

--erstellung von mehreren Tabellen mit mehreren Datensa:tzen
--created 11 tables with 1:n and m:n relationships



--create a diagram : done and saved
--mock data created from Mockaroo.com


--table 1
INSERT INTO Kunden (Vorname, Nachname, Email, Telefon, Stadt, Strasse, PLZ, IstAktiv)
VALUES
	('Julia','Schmidt','julia@example.com','030-1111','Berlin','Musterstr. 1',10115,1),
	('Mark','Fischer','mark@example.com','040-2222','Hamburg','Hauptstr. 2',20095,1),
	('Anna','Meier','anna.meier@example.com','030-3333','Berlin','Nebenweg 3',10117,1),
	('Peter','Koch','peter.koch@example.com','030-4444','Berlin','Ring 4',10119,1),
	('Lena','Becker','lena.becker@example.com','030-5555','Berlin','Gasse 5',10178,1),
	('Tom','Schneider','tom.schneider@example.com','040-6666','Hamburg','Platz 6',20097,1),
	('Sara','Weber','sara.weber@example.com','089-7777','München','Allee 7',80331,1),
	('Lukas','Klein','lukas.klein@example.com','069-8888','Frankfurt','Weg 8',60311,1),
	('Julia2','Müller','julia.mueller@example.de','030-9999','Berlin','Straße 9',10179,1),
	('Nina','Schulz','nina.schulz@example.com','030-1212','Berlin','Platz 10',10115,1),
	('Paul','Neumann','paul.neumann@example.com','030-1313','Berlin','Ring 11',10115,1),
	('Clara','Frey','clara.frey@example.com','040-1414','Hamburg','Ufer 12',20095,1),
	('Erik','Lang','erik.lang@example.com','089-1515','München','Berg 13',80331,1),
	('Mona','Hart','mona.hart@example.com','030-1616','Berlin','Linden 14',10117,1),
	('Ben','Walter','ben.walter@example.com','030-1717','Berlin','Höhe 15',10119,1),
	('Olga','Brand','olga.brand@example.com','040-1818','Hamburg','Bucht 16',20097,1),
	('Yusuf','Kaya','yusuf.kaya@example.com','069-1919','Frankfurt','Tor 17',60311,1),
	('Iris','Behr','iris.behr@example.com','030-2020','Berlin','Hauptplatz 18',10178,1),
	('Nils','Roth','nils.roth@example.com','089-2121','München','Ring 19',80331,1),
	('Tina','Wolf','tina.wolf@example.com','030-2223','Berlin','Garten 20',10115,1);

select*
	from Kunden;

--table 2
INSERT INTO Kategorien (KategorieName, Beschreibung)
VALUES
	('Elektronik', 'Smartphones, Laptops, Zubehör'),
	('Haushalt', 'Küchen- und Haushaltswaren'),
	('Bücher', 'Fachbücher und Romane'),
	('Kleidung', 'Damen- und Herrenmode'),
	('Spielzeug', 'Kinder- und Gesellschaftsspiele'),
	('Sport', 'Fitness, Outdoor');


select*
	from Kategorien;

--table 3
INSERT INTO Lieferanten (Name, Ort, EmailId, Telefon)
VALUES
	('GlobalTech GmbH', 'Berlin', 'kontakt@globaltech.de', '+49 30 123456'),
	('HomeGoods AG', 'Hamburg', 'info@homegoods.de', '+49 40 987654'),
	('BookWorld GmbH', 'München', 'service@bookworld.de', '+49 89 111222'),
	('Fashion Co', 'Düsseldorf', 'mail@fashionco.de', '+49 211 333444'),
	('PlayFun Ltd', 'Köln', 'kontakt@playfun.de', '+49 221 555666'),
	('SportPro', 'Stuttgart', 'info@sportpro.de', '+49 40 777888'),
	('KitchenKing', 'Frankfurt', 'info@kitchenking.de', '+49 69 222333'),
	('SoundMax AG', 'Berlin', 'support@soundmax.de', '+49 30 999888'),
	('StyleCo', 'Hamburg', 'hello@styleco.de', '+49 40 123987'),
	('StoryHouse Verlag', 'München', 'kontakt@storyhouse.de', '+49 89 445566');

	select*
	from Lieferanten;

--table 4

INSERT INTO Produkte (productName, KID, LID, Einzelprice, Marke)
VALUES
('Smartphone X100', 1, 1, 699.00, 'TechCorp'),
('Kopfhörer NoiseMax', 1, 8, 129.00, 'SoundMax'),
('Kochtopf 3L', 2, 2, 39.90, 'HomeBrand'),
('SQL Einstieg', 3, 3, 29.99, 'LearnBooks'),
('T-Shirt Basic', 4, 9, 19.99, 'StyleCo'),
('Brettspiel Abenteuer', 5, 5, 29.50, 'PlayFun'),
('Laufhose Pro', 6, 6, 49.90, 'SportPro'),
('Tablet S2', 1, 1, 329.00, 'TechCorp'),
('Roman Schatten', 3, 10, 12.50, 'StoryHouse'),
('Kinderpuzzle 1000', 5, 5, 14.99, 'PlayFun'),
('Wasserkocher Deluxe', 2, 2, 24.99, 'HomeGoods'),
('Fitnessmatte SoftGrip', 6, 6, 35.00, 'SportPro'),
('Bluetooth Lautsprecher Mini', 1, 8, 59.90, 'SoundMax'),
('Kaffeemaschine Compact', 2, 2, 89.00, 'KitchenKing'),
('Hemd Classic Fit', 4, 9, 34.50, 'StyleCo'),
('Kinderbuch Abenteuerland', 3, 3, 11.90, 'BookWorld'),
('Tablet-Hülle', 1, 1, 19.90, 'TechCorp'),
('Rucksack Trail', 6, 6, 69.00, 'SportPro'),
('Puzzle 500 Teile', 5, 5, 9.99, 'PlayFun'),
('Laptop UltraLight 15"', 1, 1, 999.00, 'TechCorp');


select* 
	from Produkte;


--table 5
INSERT INTO Mitarbeiter (Vorname, Nachname, EmailID, Telefone, Rolle)
VALUES
('Peter', 'Koch', 'peter.koch@shop.de', '030-4010', 'Verkauf'),
('Lena', 'Becker', 'lena.becker@shop.de', '030-4020', 'Lager'),
('Sven', 'Müller', 'sven.mueller@shop.de', '030-4030', 'Versand'),
('Laura', 'Fischer', 'laura.fischer@shop.de', '030-4040', 'Kundenservice'),
('Jan', 'Schulze', 'jan.schulze@shop.de', '030-4050', 'Buchhaltung'),
('Maya', 'Weiss', 'maya.weiss@shop.de', '030-4060', 'IT');


--table 6
INSERT INTO Bestellungen (KID, MID, Bestelldatum, Status, Lieferadresse, LifereungKosten, SubTotal, MWSt, Gesamt)
VALUES
(1, 1, GETDATE(), 'Neu', 'Musterstraße 1, Berlin', 4.99, 699.00, 132.81, 836.80),
(2, 3, GETDATE(), 'Versendet', 'Hauptstraße 5, Hamburg', 0.00, 29.99, 5.70, 35.69),
(3, 2, GETDATE(), 'Neu', 'Nebenweg 7, Berlin', 4.99, 49.90, 9.48, 64.37),
(4, 5, GETDATE(), 'Bezahlt', 'Ring 9, Berlin', 4.99, 129.00, 24.51, 158.50),
(5, 6, GETDATE(), 'Neu', 'Gasse 11, Berlin', 0.00, 39.90, 7.58, 47.48);

select* 
	from Bestellungen;


--table 7
INSERT INTO Bestellpositionen (BID, PID, Menge, Einzelpreis, Rabatt)
VALUES
(1, 1, 1, 699.00, 0.00),
(2, 4, 1, 29.99, 0.00),
(3, 7, 1, 49.90, 0.00),
(4, 2, 1, 129.00, 0.00),
(5, 3, 2, 39.90, 0.05);
select*
	from Bestellpositionen;

--table 8 
INSERT INTO Zahlung (BID, Zahlungdatum, Betrag, Zahlungsart)
VALUES
	(1, GETDATE(), 836.80, 'Kreditkarte'),
	(2, GETDATE(), 35.69, 'PayPal'),
	(3, GETDATE(), 64.37, 'Überweisung'),
	(4, GETDATE(), 158.50, 'Klarna');

select*
	from zahlung;

--table 9

INSERT INTO Bewertungen (BID, PID, KID, Beschreibung, ErstelltAm)
VALUES
(1, 1, 1, N'Ausgezeichnetes Produkt, schnelle Lieferung und gut verpackt.', GETDATE()),
(2, 4, 2, N'Das Buch war spannend und kam in perfektem Zustand an.', GETDATE()),
(3, 3, 3, N'Sehr gute Qualität, genau wie beschrieben.', GETDATE()),
(4, 2, 4, N'Toller Klang, aber die Akkulaufzeit könnte länger sein.', GETDATE()),
(5, 7, 5, N'Bequeme Laufhose, sitzt perfekt und angenehmes Material.', GETDATE()),
(1, 5, 6, N'Schönes T-Shirt, gute Passform und Stoff fühlt sich hochwertig an.', GETDATE()),
(2, 6, 7, N'Mein Sohn liebt dieses Brettspiel, super für die Familie!', GETDATE()),
(3, 8, 8, N'Das Tablet ist leicht, schnell und hat eine gute Bildschirmqualität.', GETDATE()),
(4, 9, 9, N'Sehr fesselnder Roman, habe ihn an einem Tag durchgelesen.', GETDATE()),
(5, 10, 10, N'Puzzle mit tollen Farben, alle Teile passen perfekt.', GETDATE()),
(1, 11, 11, N'Der Wasserkocher funktioniert einwandfrei und sieht schick aus.', GETDATE()),
(2, 12, 12, N'Weiche Fitnessmatte, ideal für Yoga und Gymnastik.', GETDATE()),
(3, 13, 13, N'Kleiner Lautsprecher mit erstaunlich gutem Klang.', GETDATE()),
(4, 14, 14, N'Kompakte Kaffeemaschine, leicht zu reinigen und macht guten Kaffee.', GETDATE()),
(5, 15, 15, N'Hemd sitzt gut und die Qualität ist hervorragend.', GETDATE()),
(1, 16, 16, N'Wunderschönes Kinderbuch mit tollen Illustrationen.', GETDATE()),
(2, 17, 17, N'Schutzhülle passt perfekt und wirkt sehr robust.', GETDATE()),
(3, 18, 18, N'Rucksack ist stabil, bequem und ideal für Wanderungen.', GETDATE()),
(4, 19, 19, N'Puzzlequalität könnte besser sein, manche Teile sind leicht verbogen.', GETDATE()),
(5, 20, 20, N'Laptop ist superschnell, Preis-Leistungs-Verhältnis top!', GETDATE());

select*
	from Bewertungen;
	ALTER TABLE Bewertungen DROP COLUMN BwID;


ALTER TABLE Bewertungen DROP COLUMN BewID;

ALTER TABLE Bewertungen
ADD BewID INT IDENTITY(1,1);


INSERT INTO ProduktTags (ProduktID, TagID) VALUES
	(1, 1), (1, 4),       
	(2, 1), (2, 5),       
	(3, 1), (3, 5),      
	(4, 1), (4, 4),       
	(5, 1), (5, 9),        
	(6, 2), (6, 3),        
	(7, 2), (7, 7),        
	(8, 3), (8, 5),       
	(9, 3), (9, 4),       
	(10, 10), (10, 5);     

INSERT INTO Tags ( TagName) VALUES
	( 'Elektronik'),
	('Haushalt'),
	( 'Büro'),
	( 'Gaming'),
	( 'Zubehör'),
	( 'Mode'),
	( 'Garten'),
	( 'Gesundheit'),
	( 'Sport'),
	( 'Musik');


INSERT INTO dbo.Lieferungen (BestellungID, LieferantID, TrackingNumber, Versandart, LieferKosten, Bemerkung)
VALUES
(1, 1, 'DHL123456789', 'DHL Paket', 4.99, 'Standardversand'),
(2, 2, 'UPS987654321', 'UPS Express', 9.90, 'Expresslieferung');






alter table Produkte
add Bestand int default 0 check (Bestand >= 0);


update Produkte
set Bestand = case 
    when  PID = 1 then 50
    when PID = 2 then 120
    when PID = 3 then 75
    when PID = 4 then 30
    when PID = 5 then 0
    when PID = 6 then 200
    else ABS(CHECKSUM(NEWID()) % 150) + 1  -- random 1–150 if more products exist
end;

select*
	from produkte;

--Create index 
--Wie kann ich Suchanfragen und Berichte schneller machen, wenn die Datenbank wächst?

-- Produkte
create nonclustered index IX_Produkte_ProduktName on Produkte(ProductName)
	include (Einzelprice, Bestand);

create nonclustered index IX_Produkte_Bestand ON Produkte(Bestand)
    include (ProductName, Einzelprice);

-- Bestellungen
create nonclustered index IX_Bestellungen_KID ON Bestellungen(KID)
    include (Bestelldatum, Status, Gesamt);

create nonclustered index  IX_Bestellungen_Bestelldatum ON Bestellungen(Bestelldatum)
    include (KID, Status, Gesamt);

create nonclustered index IX_Bestellungen_Status ON Bestellungen(Status)
    include (KID, Bestelldatum);

-- Bestellpositionen
create nonclustered index IX_Bestellpositionen_BestellungID ON Bestellpositionen(BID)
    include (PID, Menge, Einzelpreis);

create nonclustered index IX_Bestellpositionen_ProduktID ON Bestellpositionen(PID)
    include (BID, Menge);

-- Kunden
create nonclustered index IX_Kunden_Email ON Kunden(Email)
    include (Vorname, Nachname, Stadt);

create nonclustered index IX_Kunden_Name ON Kunden(Nachname, Vorname)
    include (Email, Stadt);

-- Mitarbeiter
create nonclustered index IX_Mitarbeiter_Rolle ON Mitarbeiter(Rolle)
    include (Vorname, Nachname, Emailid);

create nonclustered index IX_Mitarbeiter_Email ON Mitarbeiter(Emailid)
    include (Vorname, Nachname);

---no lagerlog inserted and no indexed created

-- Produktbewertungen
create nonclustered index IX_Produktbewertungen_ProduktID ON bewertungen(PID)
    include (Beschreibung, ErstelltAm);

-- ProduktTags

create nonclustered index IX_ProduktTags_ProduktID ON ProduktTags(ProduktID)
    include (TagID);

create nonclustered index IX_ProduktTags_TagID ON Produkttags(TagID )
    include (ProduktID);

-- Zahlungen
create nonclustered index IX_Zahlungen_BestellungID ON Zahlung(BID)
    include (Betrag, Zahlungdatum, Zahlungsart);

--DELIVERY
create nonclustered index IX_Lieferungen_BestellungID ON dbo.Lieferungen(BestellungID) 
	include (LieferDatum, LieferStatus);
create nonclustered index IX_Lieferungen_LieferantID ON dbo.Lieferungen(LieferantID) 
	include (LieferDatum, Lieferkosten);
create nonclustered index IX_Lieferungen_Status ON dbo.Lieferungen(LieferStatus) 
	include (BestellungID, LieferDatum);





alter table produkte
add  AnzahlderProdukte int;

select*
	FROM produkte;

alter table  produkte  drop column AnzahlderProdukte;

Alter table bestellungen add  AnzahlderProdukte int;


insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (4);
insert into bestellungen (AnzahlderProdukte) values (2);
insert into bestellungen (AnzahlderProdukte) values (2);
insert into bestellungen (AnzahlderProdukte) values (5);
insert into bestellungen (AnzahlderProdukte) values (5);
insert into bestellungen (AnzahlderProdukte) values (4);
insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (3);
insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (5);
insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (2);
insert into bestellungen (AnzahlderProdukte) values (1);
insert into bestellungen (AnzahlderProdukte) values (5);
insert into bestellungen (AnzahlderProdukte) values (4);
insert into bestellungen (AnzahlderProdukte) values (5);

select*
	FROM bestellungen ;

	update bestellungen set AnzahlderProdukte=1 where BID=1;
	update bestellungen set AnzahlderProdukte=4 where BID=2;
	update bestellungen set AnzahlderProdukte=3 where BID=3;
	update bestellungen set AnzahlderProdukte=2 where BID=4;
    update bestellungen set AnzahlderProdukte=4 where BID=5;


--To create view, I created a meaningful business question

--Welche Produkte wurden pro Bestellung verkauft?? (inner join)

create or alter view dbo.vw_Bestellungdetails as
	   select k.KID as KundeID, CONCAT (k.vorname, k.nachname) as kunden_name, k.email,
       p.PID, 
       p.einzelprice as Price_of_the_product, p.einzelprice*AnzahlderProdukte as Total_bestellung_preis,
	   b.Bestelldatum,
	   bp.BestellpositionID, -- add delivery details
	   bw.Beschreibung
	   FROM dbo.Bestellungen b
	   INNER JOIN dbo.Kunden k ON b.KID = k.KID
	   INNER JOIN dbo.Bestellpositionen bp ON b.BID = bp.BestellpositionID
	   INNER JOIN bewertungen BW ON BW.BID=B.BID
	   INNER JOIN dbo.Produkte p ON bp.PID = p.PID
	   INNER JOIN DBO.produkttags PT ON PT.ProduktID=P.PID
	   INNER JOIN TAGS T ON T.TagID=PT.ProduktID;


SELECT TOP 10 * FROM dbo.vw_Bestellungdetails;

--CREATE ANOTHER VIEW FOR FINDING OUT THE DELIVERY DETAILS ALONG WITH IT'S ORDER DETAILS (inner join)
CREATE OR ALTER VIEW  dbo.vw_lieferung_details as
select l.lieferungid, l.erstelltam as Delivery_date,
	lt.lid,
	b.bid,b.bestelldatum as order_placed_date,
	k.kid,CONCAT (k.vorname,' ',k.nachname) as Full_Name
	from lieferungen l 
	inner join lieferanten lt on l.lieferantid=lt.lid
	inner join bestellungen b on b.bid=l.bestellungid
	inner join kunden k on k.kid=b.kid;

select* from dbo.vw_lieferung_details


-- 3 Umsatz pro Kunde (aggregate + having)
CREATE OR ALTER VIEW vw_KundenUmsatz AS
SELECT 
    k.KID, k.Vorname, k.Nachname,
    COUNT(DISTINCT b.BID) AS AnzahlBestellungen,
    SUM(ISNULL(b.Gesamt,0)) AS GesamtUmsatz
FROM Kunden k
LEFT JOIN Bestellungen b ON k.KID = b.KID
GROUP BY k.KID, k.Vorname, k.Nachname
HAVING SUM(ISNULL(b.Gesamt,0)) > 0;


--4 Kunden mit/ohne Bestellung (left join)
CREATE OR ALTER VIEW vw_KundenMitOderOhneBestellungen AS
SELECT k.KID, k.Vorname, k.Nachname, b.BID AS BestellungID, b.Bestelldatum
FROM Kunden k
LEFT JOIN Bestellungen b ON k.KID = b.KID;




--create function
--To calculate Umsatzsteuer(VAT 19% in Germany)
--skalare functionen
create function dbo.fn_vatcalculator(@betrag decimal(12,2))
returns decimal (12,2)
as
begin
	return round(@betrag*0.19,2);
End;


select dbo.fn_vatcalculator(120);

--inlinefunktionen
--to create function to get the customer details based on the customer id(kunden_id)

create function dbo.fn_kundendetails(@kundenid int)
returns table
as
return
	(Select kid, CONCAT(vorname,' ',nachname) as full_name, email,telefon, stadt
	from kunden
	where kid=@kundenid
	);

select* from  dbo.fn_kundendetails(1);

--create function with joins
--Funktion mit inner join erstellen

create function dbo.fn_cust_order_details(@bestellungenid int)
returns table
as
return
	(select k.kid, CONCAT(k.vorname,' ',k.nachname) as full_name, k.email,k.telefon, k.stadt, b.bestelldatum, b.status
	from kunden k 
	inner join bestellungen b
	on k.KID=b.KID
	where b.BID=@bestellungenid);

select* from [dbo].[bestellungen];

select* from dbo.fn_cust_order_details(5);


--MSTVF function (schwelle =stock)
create function dbo.fn_ProdukteNiedrigerBestand(@schwelle int)
returns @Ergebnis table (
    ProduktID int,
    ProduktName nvarchar(200),
    Bestand int
)
as
begin
    insert into @Ergebnis
    select PID, ProductName, Bestand 
    from Produkte 
    where Bestand <= @schwelle;

    return;
end;

select * from dbo.fn_ProdukteNiedrigerBestand(2);




