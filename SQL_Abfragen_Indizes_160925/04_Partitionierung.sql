/*
	Partitionierung: 
	Aufteilung in "mehrere" Tabellen
	Einzelne Tabelle bleibt bestehen, aber intern werden die Daten partitioniert
*/

-- Anforderung
-- Partitionsfunktion: Stellt die Bereiche dar (0-100, 101-200, 201-Ende)
-- Partitionsschema: Weist die einzelnen Partitionen auf Dateigruppen zu

-- Dateigruppen erstellen per Code
ALTER DATABASE Demo7 ADD FILEGROUP GRUPPE1
ALTER DATABASE Demo7 ADD FILEGROUP GRUPPE2
ALTER DATABASE Demo7 ADD FILEGROUP GRUPPE3

-- Dateien erstellen per Code
ALTER DATABASE Demo7
ADD FILE
(
	NAME = N'Gruppe_Datei1',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLKURS\MSSQL\DATA\Gruppe_Datei1.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
) TO FILEGROUP GRUPPE1

ALTER DATABASE Demo7
ADD FILE
(
	NAME = N'Gruppe_Datei2',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLKURS\MSSQL\DATA\Gruppe_Datei2.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
) TO FILEGROUP GRUPPE2

ALTER DATABASE Demo7
ADD FILE
(
	NAME = N'Gruppe_Datei3',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLKURS\MSSQL\DATA\Gruppe_Datei3.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
) TO FILEGROUP GRUPPE3

-- Z.B Identity Wert
-- 0-100, 101-200, 200-1000
CREATE PARTITION FUNCTION pf_Zahl(int) AS
RANGE LEFT FOR VALUES(100, 200)

-- Partitionsschema muss immer eine extra Dateigruppe existieren
CREATE PARTITION SCHEME sch_ID as
PARTITION pf_Zahl TO (GRUPPE1, GRUPPE2, GRUPPE3)

------------------------------------------------------

-- Hier muss das Schema auf die Tabelle gelegt werden
CREATE TABLE M003_Test
(
	id int identity,
	zahl float
) ON sch_ID(id)

BEGIN TRAN
DECLARE @i int = 0;
WHILE @i < 1000
BEGIN
		INSERT INTO M003_Test VALUES(RAND() * 1000)
		SET @i += 1
END
COMMIT

-- Nichts besonderes zu sehen
SELECT * FROM M003_Test

-- 0-100, 101-200, 200-1000
SELECT * FROM M003_Test
WHERE id < 500

-- Übersicht über Partition verschaffen
SELECT OBJECT_NAME(object_id), * FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')

SELECT $partition.pf_Zahl(50)
SELECT $partition.pf_Zahl(150)
SELECT $partition.pf_Zahl(250)

SELECT * FROM sys.filegroups
SELECT * FROM sys.allocation_units

-- Pro Datensatz die Partition + Filegroup anhängen
SELECT * FROM M003_Test t
JOIN
(
	SELECT name, ips.partition_number
	FROM sys.filegroups fg --Name

	JOIN sys.allocation_units au
	ON fg.data_space_id = au.data_space_id

	JOIN sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED') ips
	ON ips.hobt_id = au.container_id

	WHERE OBJECT_NAME(ips.object_id) = 'M003_Test'
) x
ON $partition.pf_Zahl(t.id) = x.partition_number