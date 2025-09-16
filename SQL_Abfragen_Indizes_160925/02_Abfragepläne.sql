dbcc freeproccache
USE Northwind

-- Pläne werden als Hashwert gespeichert... blöd, wenn man mal groß und klein schreibt...

SELECT * FROM orders WHERE customerid = 'HANAR'

SELECT * FROM Orders where customerid = 'HANAR'

SELECT * FROM orders WHERE CustomerID = 'HANAR'



SELECT * FROM Orders WHERE OrderID = 10
-- tinyint

SELECT * FROM Orders WHERE OrderID = 20

SELECT * FROM Orders WHERE OrderID = 300
-- smallint

SELECT * FROM Orders WHERE OrderID = 50000
-- int

SELECT usecounts, cacheobjtype, [TEXT] FROM
	sys.dm_exec_cached_plans as p CROSS APPLY
	sys.dm_exec_sql_text(plan_handle)
	WHERE cacheobjtype = 'Compiled Plan'
	AND [Text] NOT LIKE '%dm_exec_cached_plans%'