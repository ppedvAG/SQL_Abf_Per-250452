-- MAXDOP
-- Maximum Degree of Parallelism (Maximaler Grad an Parallelität)
-- Steuerung der Anzahl Prozessorkerne pro Abfrage
-- Parallelisierung passiert von alleine

-- Kann auf drei verschiedenen Ebenen gesetzt werden
-- 1. Abfragen, 2. Datenbank, 3. Server

-- Kosten der Parallelität: Gibt die Kosten an die eine Abfrage haben muss, um parallelisiert zu werden
-- Maximaler Grad der Parallelität: Gibt die maximale Anzahl Prozessorkerne an, die eine Abfrage verwenden darf

-- Verwendung: Abfragen zu Priorisieren

SET STATISTICS time, io on

SELECT Freight, LastName, FirstName
FROM M005_Index
WHERE Freight > (SELECT AVG(Freight) FROM M005_Index)
-- Diese Abfrage wird parallelisiert durch die Zwei schwarzen Pfeile in dem gelben Kreis
--> Ausführungsplan sehen

SELECT Freight, LastName, FirstName
FROM M005_Index
WHERE Freight > (SELECT AVG(Freight) FROM M005_Index)
OPTION (MAXDOP 1)
-- CPU-Zeit = 250ms, verstrichene Zeit = 1268ms


SELECT Freight, LastName, FirstName
FROM M005_Index
WHERE Freight > (SELECT AVG(Freight) FROM M005_Index)
OPTION (MAXDOP 2)
-- CPU-Zeit = 156ms, verstrichene Zeit = 1258ms


SELECT Freight, LastName, FirstName
FROM M005_Index
WHERE Freight > (SELECT AVG(Freight) FROM M005_Index)
OPTION (MAXDOP 4)
-- CPU-Zeit = 469ms, verstrichene Zeit = 1215ms


SELECT Freight, LastName, FirstName
FROM M005_Index
WHERE Freight > (SELECT AVG(Freight) FROM M005_Index)
OPTION (MAXDOP 8)
-- CPU-Zeit = 533ms, verstrichene Zeit = 1509ms