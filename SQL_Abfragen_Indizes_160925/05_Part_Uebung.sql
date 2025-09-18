/*
	Erstelle mir eine Partitionsfunktion "pf_Datum"
	- Partitionsschema: sch_Datum

	|--------------------------------|--------------------------------|
	2021						   2022								2023
*/


-- Partitionieren nach Datum: 2021-2022-2023

-- Tabelle anlegen M003_Umsatz
-- Spalten datum, umsatz
-- Schema auf Tabelle legen!

-- Tabelle Inhalt befuellen
BEGIN TRAN
DECLARE @i int = 0
WHILE @i < 100000
BEGIN
		INSERT INTO M003_Umsatz VALUES
		(DATEADD(DAY, FLOOR(RAND() *1095), '01.01.2021'), RAND() * 1000)
		SET @i += 1
END 
COMMIT

-- Kontrolle der Partitionen
SELECT * FROM sys.allocation_units
----------------------------------------------------------------------

CREATE PARTITION FUNCTION pf_Datum(Date) AS
RANGE LEFT FOR VALUES ('31.12.2021', '31.12.2022', '31.12.2023')
-- SPLIT = Fügt eine Neue Grenze ein
-- MERGE = Tut eine Grenze die vorhanden ist entfernen

CREATE PARTITION SCHEME sch_Datum AS
PARTITION pf_Datum TO (B1, B2, B3, B4)

CREATE TABLE M003_Umsatz
(
	datum date,
	umsatz float
) ON sch_Datum(datum)

-- Kontrolle der Partitionen
SELECT * FROM M003_Umsatz t
JOIN
(
	SELECT name, ips.partition_number
	FROM sys.filegroups fg --Name

	JOIN sys.allocation_units au
	ON fg.data_space_id = au.data_space_id

	JOIN sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED') ips
	ON ips.hobt_id = au.container_id

	WHERE OBJECT_NAME(ips.object_id) = 'M003_Umsatz'
) x
ON $partition.pf_Datum(t.datum) = x.partition_number