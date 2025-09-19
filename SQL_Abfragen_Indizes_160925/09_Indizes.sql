-- Index

/*
	Table Scan: Durchsuche die gesamte Tabelle (langsam)
	Index Scan: Durchsucht bestimmte Bereiche im Index (besser)
	Index Seak: Gehe in einen Index gezielt zu den Daten hin (am besten)


	Gruppierten Index / Clustered Index
	Normaler Index, welcher sich immer selbst sortiert
	bei INSERT/UDPDATE werden die Daten herumgeschoben
	Kann nur einmal existieren pro Tabelle
	-> Kostet Performance
	Standardmäßig mit PK erstellt

	Wann brauch ich den Gruppierten Index?
	- Sehr gut bei Abfragen nach Bereich und rel. Großen Ergebnismengen: <, >, between, like


	Nicht-gruppierten Index / Non-Clustered Index
	Standardindex
	Zwei Komponenten: Schlüsselspalte, inkludierten Spalten
	Anhand der Komponenten entscheidet die DB ob der Index verwendet wird

	Wann brauch ich den Nicht-gruppierten Index?
	- Sehr gut bei Abfragen auf rel. eindeutige Werte bzw geringen Ergebnismengen
	- Kann mehrfach verwendet werden (999-Mal)
*/

SELECT * 
INTO M005_Index
FROM M004_Kompression

SET STATISTICS TIME, IO ON

-- Table Scan
SELECT * FROM M005_Index

SELECT * FROM M005_Index
WHERE OrderID >= 11000
-- Table Scan
-- Cost: 21.79%, logische Lesevorgänge: 28315, CPU-Zeit = 402ms, verstrichene Zeit = 1001ms

-- Neuer Index NCIX_OrderID
SELECT * FROM M005_Index
WHERE OrderID >= 11000
-- Index Seek
-- Cost: 2.18%, logische Lesevorgänge: 2899, CPU-Zeit = 110ms, verstrichene Zeit = 933ms

-- Indizes anschauen
SELECT OBJECT_NAME(OBJECT_ID), index_level, page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')
WHERE OBJECT_NAME(object_id) = 'M005_Index'
-- index_level 2 (Root) => Liegt über Level 1 und zeig auf dessen Seiten
-- index_level 1 (Intermediate) => Verzeichnis-Knoten über der Leaf-Ebene
-- index_level 0 (Leaf) => Unterste Schicht des B-Trees

-- Auf bestimmte (häufige) Abfragen Indizes aufbauen
SELECT CompanyName, ContactName, ProductName, Quantity * UnitPrice
FROM M005_Index
WHERE ProductName = 'Chocolade'
-- Cost: 21.24, logische Lesevorgänge: 28315, CPU-Zeit = 264ms, verstrichene Zeit = 129ms

-- Neuer Index: NCIX_ProductName
SELECT CompanyName, ContactName, ProductName, Quantity * UnitPrice
FROM M005_Index
WHERE ProductName = 'Chocolade'
-- Cost: 0.02, logische Lesevorgänge: 26, CPU-Zeit = 0ms, verstrichene Zeit = 85ms

-- Hier wird auch NCIX_ProductName durchgegangen
-- Hier fehlt die ContactName Spalte
SELECT CompanyName, ProductName,Quantity * UnitPrice
FROM M005_Index
WHERE ProductName = 'Chocolade'


SELECT CompanyName, ProductName, ContactName, Quantity * UnitPrice, Freight
FROM M005_Index
WHERE ProductName = 'Chocolade'
-- Cost: 4.94, logische Lesevorgänge: 1562, CPU-Zeit = 0ms, verstrichene Zeit = 106ms


-- Neuer Index: NCIX_Freight
SELECT CompanyName, ContactName, Phone, ProductName, Quantity * UnitPrice, Freight, FirstName, LastName
FROM M005_Index
WHERE Freight > 50


-- Ohne WHERE: Index Scan
-- Cost: 10.55, logische Lesevorgänge: 13396, CPU-Zeit = 813ms, verstrichene Zeit = 4857ms
SELECT CompanyName, ContactName, Phone, ProductName, Quantity * UnitPrice, Freight, FirstName, LastName
FROM M005_Index

---------------------------------------------------------
-- Indizierte Sicht
-- View mit Index
-- Benötigt SCHEMABINDING
-- WITH SCHEMABINDING: Solange die View existiert, kann die Tabellenstruktur nicht verändert werden
ALTER TABLE M005_Index ADD id int identity
GO


CREATE VIEW Adressen WITH SCHEMABINDING
AS
SELECT id, CompanyName, Address, City, Region, PostalCode, Country
FROM dbo.M005_Index

-- Clustered Index Scan
SELECT * FROM Adressen

-- Auch einen Clustered Index Scan
-- Abfrage auf die Tabelle verwendet hier den Index der View
SELECT id, CompanyName, Address, City, Region, PostalCode, Country
FROM dbo.M005_Index

-- Clustered Index Insert
INSERT INTO M005_Index (CompanyName, Address, City, Region, PostalCode, Country)
VALUES('PPEDV', 'Eine Straße', 'Irgendwo', NULL, NULL, NULL)


-- Clustered Index Delete
DELETE FROM M005_Index
WHERE CompanyName = 'PPEDV'






-- Wenn index_id = 0 => TableScan suche => Achten auf user_scans
SELECT 
    OBJECT_NAME(s.object_id, DB_ID()) AS TableName,
    i.name AS IndexName,
    s.index_id,
    s.user_scans,        -- Anzahl der Scans (Index- oder Table-Scans)
    s.user_seeks,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats AS s
LEFT JOIN sys.indexes AS i
    ON s.object_id = i.object_id
   AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
  AND OBJECT_NAME(s.object_id, DB_ID()) = 'M005_Index'   -- <== Tabellennamen anpassen
ORDER BY s.user_scans DESC;



-- Case-Fall gebastelt für die Datenbank Demo7
-- => Wenn index_id = 0, dann IndexName => "Heap" und TableScans nachverfolgen wie oft 
SELECT
    OBJECT_NAME(s.object_id, DB_ID()) AS TableName,
    s.index_id,
    COALESCE(i.name, 'HEAP') AS IndexName,
    CASE 
        WHEN s.index_id = 0 THEN s.user_scans        -- Heap ? Table Scan
        ELSE NULL                                   -- bei Indizes nichts ausgeben (oder s.user_scans falls du es trotzdem sehen willst)
    END AS TableScan
FROM sys.dm_db_index_usage_stats AS s
LEFT JOIN sys.indexes AS i
       ON s.object_id = i.object_id
      AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
ORDER BY TableScan DESC;



SELECT user_seeks
* avg_total_user_cost
* (avg_user_impact * 0.01) as [Index_Useful]
,igs.last_user_seek
,id.statement as [Statement]
,id.equality_columns
,id.inequality_columns
,id.included_columns
,igs.unique_compiles
,igs.user_seeks
,igs.avg_total_user_cost
,igs.avg_user_impact
FROM sys.dm_db_missing_index_group_stats as igs
INNER JOIN sys.dm_db_missing_index_groups as ig
ON igs.group_handle = ig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details as id
ON ig.index_handle = id.index_handle


---- Syntax Gruppierter Index
-- CREATE CLUSTERED INDEX <IndexName>
-- ON <TabellenName> (Schlüsselspalte)

---- Syntax Nicht-Gruppierten Index
-- CREATE NONCLUSTERED INDEX <IndexName>
-- ON <TabellenName> (Schlüsselspalte) => Das was im WHERE steht
-- INCLUDE (Inkludierten Spalten) => Das was nach dem "SELECT ..." folgt
