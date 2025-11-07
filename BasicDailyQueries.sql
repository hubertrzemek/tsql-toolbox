-------------------------------------------------------------------------------------
-- List of columns and data types for a table
--use [databaseName ];  -- Replace with  database name
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