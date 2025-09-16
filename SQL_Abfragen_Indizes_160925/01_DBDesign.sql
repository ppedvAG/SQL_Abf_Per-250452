/*
	Normalerweise:
	1. Jede Zelle sollte einen Wert haben
	2. Jeder Datensatz sollte einen Primärschlüssel
	3. Keine Beziehungen zwischen nicht-Schlüssel Spalten

	Redundanz verringern (Daten nicht doppelt speichern)
	- Weniger Speicherbedarf
	- Keine Inkonsistenz (Doppelte können nicht unterschiedlich sein)

	Seite: 
	8192B (8kB) groß
	8060B für tatsächliche Daten
	132B für Management Daten
	8 Seiten = 1 Block

	Seiten werden immer 1:1 gelesen

	Max. 700DS Seite
	Datensätze müssen komplett auf eine Seite passen
	Leerer Raum darf existieren, sollte aber minimiert werden
*/

-- dbcc: Database Console Commands
-- showcontig: Zeigt Seiteninformationen über ein Datenbankobjekt -> Seitendichte messen
dbcc showcontig('Orders') -- Seitendichte: 98.19%

-- Messungen
SET STATISTICS TIME, IO ON -- Messungstool anschalten
SET STATISTICS TIME, IO OFF -- Messungstool ausschalten
-- Anzahl der Seiten, CPU und Gesamtzeit der Abfrage in MS

SELECT * FROM Orders

CREATE DATABASE Demo7

USE Demo7

CREATE TABLE M001_Test1
(
	id int identity,
	test char(4100)
)

INSERT INTO M001_Test1
VALUES ('XYZ')
GO 20000

dbcc showcontig('M001_Test1')
-- Seiten: 20000
-- Seitendichte: 50.79%


USE Northwind

-- alle DS der Tabelle Orders aus dem Jahr 1997 (OrderDate) (3x Abfragen mindestens)

-- 1. Logische Lesevorgänge = 22, CPU-Zeit = 0ms, verstrichene Zeit = 100ms
SELECT * FROM Orders WHERE OrderDate LIKE '%1997%'

-- 2. Logische Lesevorgänge = 22, CPU-Zeit = 0ms, verstrichene Zeit = 111ms
SELECT * FROM Orders 
WHERE OrderDate BETWEEN '01.01.1997' AND '31.12.1997'

-- 3. Logische Lesevorgänge = 22, CPU-Zeit = 0ms, verstrichene Zeit = 66ms
SELECT * FROM Orders 
WHERE YEAR(OrderDate) = 1997

-- 4. Logische Lesevorgänge = 22, CPU-Zeit = 0ms, verstrichene Zeit = 70ms
SELECT * FROM Orders 
WHERE OrderDate BETWEEN '01.01.1997 00:00:00.000' AND '31.12.1997 23:59:59.997'


CREATE TABLE M001_Test2
(
	id int identity(1, 1),
	test varchar(4100)
)

INSERT INTO M001_Test2
VALUES ('XYZ')
GO 20000

-- 700 DS Limit getroffen
dbcc showcontig('M001_Test2') -- Seiten: 52
-- Seitendichte: 95.01%

-- Dynamische Verwaltungssichten:
-- sys.dm_db_index_physical_stats: Gibt einen Gesamtüberblick über die Seiten der Datenbank
SELECT OBJECT_NAME(object_id), *
FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')
-- WIchtig: index_id, partition_number, index_type_desc, page_count, avg_page_space_used_in_percent

-- Wann ist eine gewisse Seitendichte gut?
-- ab 70% => OK
-- ab 80% => gut
-- ab 90% => Sehr gut

--> Weniger Seiten -> Weniger Daten laden -> bessere Performance

-- Datentypen
-- varchar: 1B pro Zeichen
-- char: 1B pro Zeichen (fixe Größe)
-- nvarchar: 2B pro Zeichen => ASCII-Zeichen = UTF-16
-- text: nicht verwenden, alternative varchar(max)

-- Numerische Typen
-- int: 4B, häufig für Spalten verwendet
-- tinyint: 1B, smallint: 2B, bigint: 8B

-- money: 8B, smallmoney: 4B => 213k

-- float: 8B
-- float(n) 1-53
-- 1 - 24 => 4B => Rundung auf 7 Stellen genau
-- 25-53 => 8B => Rundung auf 15 Stellen genau
-- decimal(x, y) => x Stellen insgesamt, davon sind y Nachkommastellen
-- decimal(10,2) => 10 Stellen insgesamt, davon sind 2 Nachkommastellen
-- decimal(7,5) => 7 Stellen Insgesamt, davon sind 5 Nachkommastellen
-- 20,75345

-- Datumswerte
-- date: (YYYY-MM-DD) bis (9999-12-31)
-- time: (hh:mm:ss.nnnnnnn) bis (23:59:59.9999999)
-- datetime: (YYYY-MM-DD hh:mm:ss.mmm) bis (9999-12-31 23:59:59.997)
-- datetime2: (YYYY-MM-DD hh:mm:ss.nnnnnnn) bis (9999-12-31 23:59:59.9999999)
-- smalldatetime (YYYY-MM-DD hh:mm:ss) bis (1900-01-01 bis 2079-06-06)

CREATE TABLE M001_TestDecimal
(
	id int identity,
	zahl decimal(2, 1)
)

BEGIN TRAN
DECLARE @i int = 0
WHILE @i < 20000
BEGIN
	INSERT INTO M001_TestDecimal VALUES(2.2)
	SET @i += 1
END
COMMIT

dbcc showcontig('M001_TestDecimal')
-- Seiten: 47, Seitendichte: 94.61%

USE Northwind

SELECT * FROM PurchasingOrders

BEGIN Transaction

UPDATE PurchasingOrders
SET TestDaten = 5
WHERE ID = 1

COMMIT		-- => Tut die Änderungen übernehmen
ROLLBACK	-- => Tut die Änderung zurücksetzen