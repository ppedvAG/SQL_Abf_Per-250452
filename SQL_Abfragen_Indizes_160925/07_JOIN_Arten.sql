/*
	SQL Server versucht aus einer Reihen von Ausf�hrungspl�nen
	die er vorab ermittelt den g�nstigsten herauszufinden

	Meist stimmt das. Allerdings kann man "Auff�lligkeiten" entdecken
	

	INNER HASH JOIN
	es wird eine Hashtabelle zu ermitteln der �bereinstimmenden 
	JOIN Spalten der Tabellen
	=> Gilt bei gro�en Tabellen, leicht parallelisierbar, Index vorhanden


	INNER MERGE JOIN
	beide Tabellen gleichzeitig einmal durchsucht
	das kann nur funktionierten wenn sortiert
	(entweder CLIX oder Sortier Operator)


	INNER LOOP JOIN
	kleine Tabellen wird zeilenweise durchlaufen pro Zeile
	wird in der gr��eren Tabelle nach dem Wert gesucht
	- gut, wenn eine Tabelle bzw (WHERE) Ergebnis sehr klein ist und 
	die gr��ere sortiert ist.
	
*/

SELECT * FROM Customers c
INNER HASH JOIN Orders o on o.CustomerID = c.CustomerID

-- Sortieroperator wird verwendet, obwohl kein ORDER BY in der Abfrage ist
SELECT * FROM Customers c
INNER MERGE JOIN Orders o on o.CustomerID = c.CustomerID

SELECT * FROM Customers c
INNER LOOP JOIN Orders o on o.CustomerID = c.CustomerID