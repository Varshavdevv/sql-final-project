--create function
--Das unternhemen möchte Umsatzsteuer berechnen (VAT 19% in Germany)
--To calculate Umsatzsteuer
--skalare functionen

create function dbo.fn_vatcalculator(@betrag decimal(12,2))
returns decimal (12,2)
as
begin
	return round(@betrag*0.19,2);
End;


select dbo.fn_vatcalculator(120) as vat;
select dbo.fn_vatcalculator(1000) as vat;


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
--Das Unternehmen  möchte seinen Kundenservice verbessern, 
--indem Mitarbeiter schnell die Kundendetails zu einer bestimmten Bestellung einsehen können.

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


--(schwelle =stock)
--Das Unternehmen möchte die Details zu seinen Lagerbeständen erfahren.
--The company would like to know the details of its stocks.

create function dbo.fn_ProdukteNiedrigerBestand(@schwelle int)
returns @Ergebnis table (
		ProduktID int,
		ProduktName nvarchar(200),
		Bestand int
)
as
begin
    insert into @Ergebnis
    select PID, ProductName,Bestand 
    from Produkte 
    where Bestand <= @schwelle;

    return;
end;

select * from dbo.fn_ProdukteNiedrigerBestand(20);




