/*
	Dateigruppen:
	Datenbank aufteilen auf mehrere Dateien, und verschiedene Datentr‰ger in 
	weiterer Folge
	[Primary]: Hauptgruppe, existiert immer, enth‰lt standarm‰ﬂig alle Files

	Dateien:
	Das Hauptfile hat die Endung .mdf
	Weitere Datei hat die Endung .ndf
	Log Files haben die Endungen .ldf
*/

USE Demo7

/*
	Rechtsklick auf die Datenbank => Eigenschaften
	Dateigruppen
		- Hinzuf¸gen, Namen vergeben
	Dateien
		- Hinzuf¸gen, Namen vergeben, Dateigruppe, Maximale Grˆﬂe, Pfad, Dateinamen
*/


CREATE TABLE M002_FG2
(
	id int identity,
	test char(4100)
)

INSERT INTO M002_FG2
VALUES('XYZ')
GO 20000

-- Wie verschiebe ich eine Tabelle von Primary auf meine "Sekund‰r"

-- Funktioniert nicht
--ALTER TABLE M002_FG2
--(
--	id int identity,
--	test char(4100)
--) ON Sekund‰r

-- Lˆsung: Neu erstellen, Daten verschieben, Alte Tabelle Lˆschen
CREATE TABLE M002_FG2_2
(
	id int,
	test char(4100)
) ON Sekund‰r

INSERT INTO M002_FG2_2
SELECT * FROM M002_FG2

SELECT * FROM M002_FG2_2

-- Identity hinzuf¸gen per Designer
-- Extras => Optionen => Designer => Speichern von ƒnderungen verhindern, die die Neuerstellung
-- der Tabelle erfordern => Ausschalten

-- Salamitaktik
-- Groﬂe Tabellen in kleinere Tabellen aufteilen
-- Bonus: mit Partitionierten Sicht

CREATE TABLE M002_Umsatz
(
	datum date,
	umsatz float
)

BEGIN TRAN
DECLARE @i int = 0
WHILE @i < 100000
BEGIN
		INSERT INTO M002_Umsatz VALUES
		(DATEADD(DAY, FLOOR(RAND() *1095), '01.01.2021'), RAND() * 1000)
		SET @i += 1
END 
COMMIT

SELECT * FROM M002_Umsatz
ORDER BY DATUM DESC

SELECT * FROM M002_Umsatz
WHERE YEAR(datum) = 2021

-------------------------------------------------

CREATE TABLE M002_Umsatz2021
(
	datum date,
	umsatz float
)

INSERT INTO M002_Umsatz2021
SELECT * FROM M002_Umsatz WHERE YEAR(datum) = 2021

-------------------------------------------------
CREATE TABLE M002_Umsatz2022
(
	datum date,
	umsatz float
)

INSERT INTO M002_Umsatz2022
SELECT * FROM M002_Umsatz WHERE YEAR(datum) = 2022

-------------------------------------------------
CREATE TABLE M002_Umsatz2023
(
	datum date,
	umsatz float
)

INSERT INTO M002_Umsatz2023
SELECT * FROM M002_Umsatz WHERE YEAR(datum) = 2023
GO
-- Partitionierte Sicht

CREATE VIEW UmsatzGesamt
AS
SELECT * FROM M002_Umsatz2021
UNION ALL 
SELECT * FROM M002_Umsatz2022
UNION ALL
SELECT * FROM M002_Umsatz2023

SELECT * FROM UmsatzGesamt -- Partitionierte View
WHERE datum >= '01.01.2021' AND datum <= '31.12.2021'
-- 0,39 Kosten

SELECT * FROM M002_Umsatz -- Tabelle
WHERE datum >= '01.01.2021' AND datum <= '31.12.2021'
-- 0,30 Kosten