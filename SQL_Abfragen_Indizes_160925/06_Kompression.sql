-- Kompression

-- Daten verkleinern
--> Weniger Daten werden geladen, beim dekomprimieren wird aber CPU-Leistung verwendet

-- Zwei verschiedene Komprimierungstypen

-- Row & Page Kompression

USE Northwind;
SELECT  Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.Freight, Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.Address, Customers.City, 
        Customers.Region, Customers.PostalCode, Customers.Country, Customers.Phone, Orders.OrderID, Employees.EmployeeID, Employees.LastName, Employees.FirstName, Employees.Title, [Order Details].UnitPrice, 
        [Order Details].Quantity, [Order Details].Discount, Products.ProductID, Products.ProductName, Products.UnitsInStock
INTO Demo7.dbo.M004_Kompression
FROM    [Order Details] INNER JOIN
        Products ON Products.ProductID = [Order Details].ProductID INNER JOIN
        Orders ON [Order Details].OrderID = Orders.OrderID INNER JOIN
        Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
        Customers ON Orders.CustomerID = Customers.CustomerID

USE Demo7

INSERT INTO M004_Kompression
SELECT * FROM M004_Kompression
GO 8

SELECT COUNT(*) FROM M004_Kompression

SET STATISTICS TIME, IO ON


-- Ohne Kompression: Logische Lesevorgänge: 28288, CPU-Zeit = 1375ms
-- verstrichene Zeit = 8710ms
SELECT * FROM M004_Kompression

USE [Demo7]
ALTER TABLE [dbo].[M004_Kompression] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = ROW)

-- mit Row Kompression: Logische Lesevorgänge: 15842, CPU-Zeit = 2360ms
-- verstrichene Zeit = 9385ms
SELECT * FROM M004_Kompression

USE [Demo7]
ALTER TABLE [dbo].[M004_Kompression] REBUILD PARTITION = ALL
WITH
(DATA_COMPRESSION = PAGE)

-- Page Kompression: Logische Lesevorgänge: 7579, CPU-Zeit = 4328ms
-- verstrichene Zeit = 14165ms
SELECT * FROM M004_Kompression
