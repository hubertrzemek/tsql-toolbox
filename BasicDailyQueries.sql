--Version
SELECT @@VERSION AS SQLServerVersion;
-------------------------------------------------------------------------------------
-- User
SELECT SUSER_NAME() AS CurrentUser,
       USER_NAME()  AS DatabaseUser;
-------------------------------------------------------------------------------------
SELECT
  [col].[COLUMN_NAME],
  [col].[DATA_TYPE],
  [col].[CHARACTER_MAXIMUM_LENGTH],
  [col].[IS_NULLABLE]
FROM
  [INFORMATION_SCHEMA].[COLUMNS] AS [col]
WHERE
  [col].[TABLE_NAME] = 'tableName' -- Replace with table name
-------------------------------------------------------------------------------------
-- Get Connection Network Details
SELECT
  CONNECTIONPROPERTY('client_net_address') AS ClientIP, -- Client IP address
  CONNECTIONPROPERTY('local_net_address') AS ServerIP, -- Server IP address
  CONNECTIONPROPERTY('protocol_type') AS Protocol,
  CONNECTIONPROPERTY('net_transport') AS Transport;
-------------------------------------------------------------------------------------
-- Databases
SELECT 
    name AS DatabaseName,
    state_desc AS State,
    recovery_model_desc AS RecoveryModel,
    compatibility_level,
    create_date
FROM sys.databases
ORDER BY name;
-------------------------------------------------------------------------------------
-- List of columns and data types for a table
--use [databaseName ];  -- Replace with  database name
-------------------------------------------------------------------------------------
-- Sessions
SELECT
    s.session_id,
    s.login_name,
    s.status,
    r.status AS request_status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time,
    r.blocking_session_id,
    DB_NAME(r.database_id) AS DBName
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
WHERE s.is_user_process = 1
ORDER BY r.cpu_time DESC;
-------------------------------------------------------------------------------------
-- Memory usage
SELECT 
    total_physical_memory_kb/1024 AS TotalRAM_MB,
    available_physical_memory_kb/1024 AS FreeRAM_MB,
    total_page_file_kb/1024 AS PageFile_MB,
    available_page_file_kb/1024 AS FreePageFile_MB,
    system_memory_state_desc
FROM sys.dm_os_sys_memory;
-------------------------------------------------------------------------------------
-- The most resource-intensive queries"
SELECT TOP 20
    qs.total_elapsed_time / qs.execution_count AS AvgTime,
    qs.execution_count,
    qs.total_worker_time AS CPUTime,
    qs.total_logical_reads AS LogicalReads,
    SUBSTRING(qt.text, 1, 2000) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY AvgTime DESC;
-------------------------------------------------------------------------------------
-- The largest tables in the database
SELECT 
    t.name AS TableName,
    SUM(p.rows) AS Row_Count,
    SUM(a.total_pages)*8/1024 AS TotalSize_MB,
    SUM(a.used_pages)*8/1024 AS Used_MB,
    SUM(a.data_pages)*8/1024 AS Data_MB
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
GROUP BY t.name
ORDER BY TotalSize_MB DESC;
-------------------------------------------------------------------------------------









