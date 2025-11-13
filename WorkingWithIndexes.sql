-- List All Indexes in the Database
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    i.index_id,
    i.type_desc,
    i.is_unique,
    i.is_primary_key
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.index_id > 0
ORDER BY t.name, i.index_id;

-- List All Indexes for a Specific Table
SELECT 
    i.name AS IndexName,
    i.index_id,
    i.type_desc,
    i.is_unique
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.TableName')
    AND i.index_id > 0;


-- Find the Table on Which an Index Is Created
SELECT 
    i.name AS IndexName,
    t.name AS TableName,
    s.name AS SchemaName
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.name = 'YourIndexName';

-- Find Columns Used by a Specific Index
SELECT
    i.name AS IndexName,
    t.name AS TableName,
    c.name AS ColumnName,
    ic.key_ordinal,
    ic.is_included_column,
    ic.is_descending_key
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c 
    ON c.object_id = ic.object_id AND c.column_id = ic.column_id
JOIN sys.tables t
    ON t.object_id = i.object_id
WHERE i.name = 'YourIndexName'
ORDER BY ic.is_included_column, ic.key_ordinal;


-- Find All Indexes That Include a Specific Column

SELECT
    t.name AS TableName,
    i.name AS IndexName,
    c.name AS ColumnName,
    ic.key_ordinal,
    ic.is_included_column
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c 
    ON ic.object_id = c.object_id AND ic.column_id = c.column_id
JOIN sys.tables t 
    ON t.object_id = i.object_id
WHERE c.name = 'ColumnName'
ORDER BY t.name, i.name;


-- Check Index Fragmentation
SELECT
    DB_NAME() AS DatabaseName,
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;


-- Check Index Usage Statistics
SELECT 
    DB_NAME(database_id) AS DatabaseName,
    OBJECT_NAME(object_id) AS TableName,
    index_id,
    user_seeks,
    user_scans,
    user_lookups,
    user_updates
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID()
ORDER BY user_scans DESC;



-- Find Unused Indexes
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats u
    ON i.object_id = u.object_id AND i.index_id = u.index_id 
        AND u.database_id = DB_ID()
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.index_id > 0
  AND u.index_id IS NULL
ORDER BY t.name;


-- Find Missing Indexes Suggested by the Optimizer
SELECT
    DB_NAME(mid.database_id) AS DatabaseName,
    OBJECT_NAME(mid.object_id) AS TableName,
    migs.unique_compiles,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.avg_user_impact
FROM sys.dm_db_missing_index_group_stats migs
JOIN sys.dm_db_missing_index_groups mig
    ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid
    ON mig.index_handle = mid.index_handle
ORDER BY migs.avg_user_impact DESC;

-- Create Index Examples (Nonclustered, Clustered, INCLUDE)
CREATE INDEX IX_Table_Column
ON dbo.Table (Column);

CREATE INDEX IX_Table_ColumnA
ON dbo.Table (ColumnA)
INCLUDE (ColumnB, ColumnC);

CREATE CLUSTERED INDEX IX_Table_Clustered
ON dbo.Table (ID);




-- Drop an Index
DROP INDEX IX_Table_Column ON dbo.Table;
