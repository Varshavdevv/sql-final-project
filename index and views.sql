--Create index 
--Wie kann ich Suchanfragen und Berichte schneller machen, wenn die Datenbank wächst?
-- fur 9 tabelle habe ich non-clustred index erstellt.
-- Produkte
create nonclustered index IX_Produkte_ProduktName on Produkte(ProductName)
	include (Einzelprice, Bestand);

create nonclustered index IX_Produkte_Bestand ON Produkte(Bestand)
    include (ProductName, Einzelprice);

select* from produkte

SELECT ProductName, Einzelprice, Bestand
FROM Produkte
WHERE ProductName LIKE 'Smartphone%';

SELECT ProductName, Einzelprice, Bestand
FROM Produkte
WHERE ProductName LIKE 'Puzzle%';


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
	   INNER JOIN dbo.Bestellpositionen bp ON b.BID = bp.BID
	   INNER JOIN bewertungen BW ON BW.BID=B.BID
	   INNER JOIN dbo.Produkte p ON bp.PID = p.PID
	   INNER JOIN DBO.produkttags PT ON PT.ProduktID=P.PID
	   INNER JOIN TAGS T ON T.TagID=PT.TagID;


select top 10 * FROM dbo.vw_Bestellungdetails;

--CREATE ANOTHER VIEW FOR FINDING OUT THE DELIVERY DETAILS ALONG WITH IT'S ORDER DETAILS (inner join)
create or alter view dbo.vw_lieferung_details as
select l.lieferungid, l.erstelltam as Delivery_date,
	lt.lid,
	b.bid,b.bestelldatum as order_placed_date,
	k.kid,CONCAT (k.vorname,' ',k.nachname) as Full_Name
	from lieferungen l 
	inner join lieferanten lt on l.lieferantid=lt.lid
	inner join bestellungen b on b.bid=l.bestellungid
	inner join kunden k on k.kid=b.kid;

select* from dbo.vw_lieferung_details;


-- 3 Umsatz pro Kunde (aggregate + having)
create or alter view vw_KundenUmsatz AS
SELECT 
    k.KID, k.Vorname, k.Nachname,
    COUNT(DISTINCT b.BID) AS AnzahlBestellungen,
    SUM(ISNULL(b.Gesamt,0)) AS GesamtUmsatz
from Kunden k
left join Bestellungen b ON k.KID = b.KID
group by k.KID, k.Vorname, k.Nachname
having SUM(ISNULL(b.Gesamt,0)) > 0;

select* from vw_KundenUmsatz;
--4 Kunden mit/ohne Bestellung (left join)
create or alter view vw_KundenMitOderOhneBestellungen AS
select k.KID, k.Vorname, k.Nachname, b.BID AS BestellungID, b.Bestelldatum
from Kunden k
left join Bestellungen b ON k.KID = b.KID;

select* from vw_KundenUmsatz;
---*end views*---