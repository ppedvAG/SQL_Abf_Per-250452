-- Profiler
-- Live-Verfolgung was auf der DB passiert
-- Kann in weiterer Folge f�r den DB-Optimierer verwendet werden

SELECT * FROM Customers

-- Extras -> SQL Server Profiler

-- Einstellungen auf der ersten Seite setzen
-- Events ausw�hlen auf dem zweiten Reiter
---- StmtStarted
---- StmtCompleted
---- BatchStarted
---- BatchCompleted


-----------------------------------------------

-- Nach der Trace => Datenbankoptimierungsratgeber

-- Extras => Datenbankoptimierungsratgeber

-- Trace Datei laden oder Abfragespeicher ausw�hlen

-- Tuning Optionen => Indizes und/oder Partitionen ausw�hlen

-- Oben => Starte Analyse

SELECT * FROM sys.dm_exec_sessions
WHERE host_process_id = 11744

-- Session ID 52
KILL 52