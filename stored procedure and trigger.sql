--Stored procedure 
---Wie kann ich alle verfügbaren Produkte in meinem Shop sehen?
create or alter procedure sp_GetAllProducts
as
begin
 set nocount on;
    select 
        PID,
        ProductName,
        Einzelprice,
        Bestand
    from Produkte
    order by ProductName;
end;

exec sp_GetAllProducts;


--Wie kann ich alle Produkte finden, die zu einem bestimmten Tag oder einer bestimmten Kategorie gehören?
create or alter procedure sp_GetProductsByTag
    @TagName nvarchar(50)
as
begin
	set nocount on
    select 
        p.PID,
        p.productName,
        p.Einzelprice,
        t.TagName
    from Produkte p
    INNER JOIN ProduktTags pt on p.PID = pt.ProduktID
    INNER JOIN Tags t on pt.TagID = t.TagID
    where t.TagName = @TagName
    order by p.productName;
end;
GO

exec sp_GetProductsByTag @TagName = 'Elektronik';

create or alter procedure sp_UpdateProductStock
    @ProductID int,
    @NewStock int
as
begin
    set nocount on;

    if not exists(select 1 from Produkte where PID = @ProductID)
    begin
        print 'Product not found!';
        return;
    end

    update Produkte
    set Bestand = @NewStock
    where PID = @ProductID;

    PRINT 'Product stock updated successfully!';
END;
exec sp_UpdateProductStock @Productid=2, @newstock=50;

exec sp_UpdateProductStock @Productid=995, @newstock=20;


select* from produkte;





create or alter procedure sp_bidupdate --bestellungupdate

	@kundenid int
as
begin 
	set nocount on;
if not exists (Select 1 from kunden where kid=@kundenid)
begin
 print('Customer not available')
 return
end
 update bestellungen
	 set status='neu bestellungen'
	 where kid=@kundenid
	 print 'New order details updated';
 end;
 drop procedure sp_bidupdate;
 exec sp_bidupdate @kundenid=1;

 select* from [dbo].[bestellungen];



--this table allow us to pass multiple order lines
create type dbo.BestellZeileType as table(
    ProduktID int,
    Menge int,
    Rabatt decimal(4,2) null
);

--create stored procedure
--Was passiert im System, wenn ein Kunde eine neue Bestellung aufgibt?


create OR alter procedure dbo.sp_BestellungErstellen
    @KundeID int,
    @MitarbeiterID int = NULL,
    @Lieferadresse nvarchar(400) = NULL,
    @Lieferkosten decimal(10,2) = 0,
    @BestellZeilen dbo.BestellZeileType readonly,
    @NeueBestellungID int output,
    @Fehler nvarchar(400) output
as
begin
    set nocount on;

    SET @NeueBestellungID = NULL;
    SET @Fehler = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        --1 Validation
        IF NOT EXISTS (SELECT 1 FROM Kunden WHERE KID = @KundeID)
        BEGIN
            SET @Fehler = N'Kunde existiert nicht.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM @BestellZeilen)
        BEGIN
            SET @Fehler = N'Keine Bestellzeilen übergeben.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2️ Bestellungskopf anlegen
        INSERT INTO Bestellungen (KID, MID, Lieferadresse, Bestelldatum, Status, LifereungKosten)
        VALUES (@KundeID, @MitarbeiterID, @Lieferadresse, GETDATE(), N'In Bearbeitung', @Lieferkosten);
--when you insert a new row into a table with an IDENTITY column, SCOPE_IDENTITY() gives you the newly created ID for that row.
        SET @NeueBestellungID = SCOPE_IDENTITY();

        -- 3️ Bestellpositionen einfügen (mit aktuellem Preis)
        insert into Bestellpositionen (BID, PID, Menge, Einzelpreis, Rabatt)
        select 
            @NeueBestellungID, 
            p.PID, 
            bz.Menge, 
            p.Einzelprice, 
            ISNULL(bz.Rabatt,0)
        from @BestellZeilen bz
        INNER JOIN Produkte p ON p.PID = bz.ProduktID;

        -- 4️ Subtotal berechnen
        declare @Sub decimal(12,2) = (
            select SUM(Menge * Einzelpreis * (1 - Rabatt))
            from Bestellpositionen
            where BID = @NeueBestellungID
        );

        -- 5️ MwSt mit Funktion berechnen
        declare @MwSt decimal(12,2) = dbo.fn_BerechneMwSt(@Sub);

        -- 6️ Gesamtbetrag inkl. Lieferkosten
        declare @Gesamt decimal(12,2) = @Sub + @MwSt + ISNULL(@Lieferkosten,0);

        -- 7️ Bestellungen-Tabelle updaten
        update Bestellungen
        set SubTotal = @Sub,
            MWst = @MwSt,
            Gesamt = @Gesamt
        where BID = @NeueBestellungID;

        -- 8️ Bestand reduzieren
        update p
        set p.Bestand = p.Bestand - bp.Menge
        from Produkte p
        inner join Bestellpositionen bp ON p.PID = bp.PID
        where bp.BID = @NeueBestellungID;

        -- 9️ LagerLog-Eintrag
        insert into LagerLog (PID, Veränderung, Grund, GeändertAm)
        select 
            bp.PID, 
            -bp.Menge, 
            CONCAT('Bestellung ', @NeueBestellungID), 
            GETDATE()
        from Bestellpositionen bp
        where bp.BID = @NeueBestellungID;

        commit transaction;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Fehler = ERROR_MESSAGE();
    END CATCH
END;
GO


---Trigger
---Business question
--INSERT trigger: inserted contains the new rows; deleted is empty.

--UPDATE trigger: deleted contains the old rows, inserted contains the new rows.

--DELETE trigger: deleted contains the deleted rows; inserted is empty.


create table lagerlog
	(lagerlogid int,
	produktid int,
	Veränderung decimal(12,2),
	Grund nvarchar(500),
	logdatum datetime default getdate()
);


create trigger trg_AfterInsert_Bestellpositionen
on dbo.bestellpositionen
after insert
as
begin
    insert into LagerLog (ProduktID, [Veränderung], Grund)
    select i.PID, -i.Menge, CONCAT('Bestellposition eingefügt (BestellungID=', i.BID, ')')
    from inserted i;
end;
go

-- b) AFTER UPDATE auf Produkte: Preisänderungen protokollieren
create table PreisAudit (
    PreisAuditID int identity primary key,
    ProduktID int,
    AlterPreis decimal(10,2),
    NeuerPreis decimal(10,2),
    GeaendertAm datetime DEFAULT getdate(),
    GeaendertVon int NULL
);



--delete d contains the old rows and insert i contains the new ones
create trigger trg_AfterUpdate_ProduktePreis
ON Produkte
after update
AS
begin

    insert into PreisAudit (ProduktID, AlterPreis, NeuerPreis)
    select d.PID, d.Einzelprice, i.Einzelprice
    from deleted d
    join inserted i ON d.PID = i.PID
    where ISNULL(d.Einzelprice,-1) <> ISNULL(i.Einzelprice,-1);
end;

select* from produkte  where pid =1;

UPDATE Produkte
SET Einzelprice = 19.99
WHERE PID =1;

UPDATE Produkte
SET Einzelprice = 30.00
WHERE PID =6;
select* from PreisAudit;



select* from Lieferungen;

create table geliefert_bestellung
	(GlID int identity primary key,
	LieferungID int,
	BestellungID int,
	 datetime default getdate()
);

create trigger trg_afterupdate_lieferungen
on dbo.lieferungen
after update
as
begin
	insert into geliefert_bestellung(LieferungID,BestellungID,Erstelltam)
	select i.LieferungID, i.BestellungID,i.Erstelltam
	from deleted d 
	join inserted i on d.LieferungID=i.LieferungID
	where d.Lieferstatus='Geliefert';
end;


select* from geliefert_bestellung;

UPDATE dbo.lieferungen
SET Lieferstatus = 'Geliefert'
WHERE LieferungID = 10;


-- create audit table (run only if not present)
--create or alter trigger that logs when LieferStatus changes to 'Geliefert'

CREATE OR ALTER TRIGGER dbo.trg_afterupdate_lieferungen
ON dbo.lieferungen
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.geliefert_bestellung (LieferungID, BestellungID, erstelltam)
        SELECT
            i.LieferungID,
            i.BestellungID,
            getdate()
        FROM inserted i
        JOIN deleted d ON i.LieferungID = d.LieferungID
        WHERE
            ISNULL(i.LieferStatus, '') = 'Geliefert'
            AND ISNULL(d.LieferStatus, '') <> 'Geliefert'
            AND NOT EXISTS (
                SELECT 1 FROM dbo.geliefert_bestellung gb WHERE gb.LieferungID = i.LieferungID
            );
    END TRY
    BEGIN CATCH
        
    END CATCH;
END;
GO


-- check audit table
SELECT * FROM dbo.geliefert_bestellung WHERE LieferungID = 15;
