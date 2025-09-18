/*
	SQL Server versucht aus einer Reihen von Ausf¸hrungspl‰nen
	die er vorab ermittelt den g¸nstigsten herauszufinden

	Meist stimmt das. Allerdings kann man "Auff‰lligkeiten" entdecken
	

	INNER HASH JOIN
	es wird eine Hashtabelle zu ermitteln der ¸bereinstimmenden 
	JOIN Spalten der Tabellen
	=> Gilt bei groﬂen Tabellen, leicht parallelisierbar, Index vorhanden


	INNER MERGE JOIN


	INNER LOOP JOIN
*/

SELECT * FROM Customers c
INNER HASH JOIN Orders o on o.CustomerID = c.CustomerID

