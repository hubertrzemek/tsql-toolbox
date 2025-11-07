-- Current date/time variable
DECLARE @d DATETIME = GETDATE();     -- Local server time (server time zone)

-- Examples of different date/time data types
SELECT
    CAST(GETDATE() AS date)             AS [DATE],            -- Date only (no time)
    CAST(GETDATE() AS time)             AS [TIME],            -- Time only (no date)
    CAST(GETDATE() AS smalldatetime)    AS [SMALLDATETIME],   -- Rounded to the nearest minute
    CAST(GETDATE() AS datetime)         AS [DATETIME],        -- Legacy type, ~3.33 ms precision
    CAST(SYSDATETIME() AS datetime2(7)) AS [DATETIME2],       -- High precision, recommended
    SYSDATETIMEOFFSET()                 AS [DATETIMEOFFSET];  -- Includes time zone offset

-- Adding and subtracting date parts
SELECT 
    DATEADD(day, 7, CAST(GETDATE() AS date))     AS Plus7Days,     -- Adds 7 days to today's date
    DATEADD(month, -1, SYSDATETIME())            AS Minus1Month;   -- Subtracts 1 month from current datetime 

-- Differences between dates (calculated in "date boundaries", not full calendar units)
SELECT 
    DATEDIFF(day, '2025-01-01', GETDATE())        AS DaysSince,     -- Number of day boundaries crossed
    DATEDIFF(hour, '2025-01-01 00:00', GETDATE()) AS HoursSince;    -- Number of hour boundaries crossed

-- Constructing date/time from individual parts
SELECT 
    DATEFROMPARTS(2025, 11, 07)                   AS DateOnly,      -- Builds a DATE value (YYYY-MM-DD)
    DATETIME2FROMPARTS(2025, 11, 07, 13, 45, 0, 0, 7) AS ExactDateTime2; 
    -- Builds a DATETIME2(7): (year, month, day, hour, minute, second, fractions, precision)

-- Extracting date parts (DATEPART / DATENAME)
SELECT 
    DATEPART(year,  GETDATE()) AS YearNum,     -- Numeric year (e.g., 2025)
    DATEPART(month, GETDATE()) AS MonthNum,    -- Numeric month (1–12)
    DATEPART(day,   GETDATE()) AS DayNum,      -- Numeric day of the month (1–31)
    DATENAME(weekday, GETDATE()) AS DayName,   -- Full weekday name (depends on session language)
    DATENAME(month,   GETDATE()) AS MonthName, -- Full month name (depends on session language)
    DATEPART(iso_week, GETDATE()) AS ISOWeek   -- ISO week number (ISO-8601: week starts on Monday)

 ------------------------------------------------------------------------------------------------------------
 -- Common date filters 
 --Today:
WHERE YourDateCol >= CAST(GETDATE() AS date)
  AND YourDateCol <  DATEADD(day, 1, CAST(GETDATE() AS date));

--Yesterday:
WHERE YourDateCol >= DATEADD(day, -1, CAST(GETDATE() AS date))
  AND YourDateCol <  CAST(GETDATE() AS date);

--Last 7 days (including today):
WHERE YourDateCol >= DATEADD(day, -6, CAST(GETDATE() AS date))
  AND YourDateCol <  DATEADD(day, 1, CAST(GETDATE() AS date));
--Last 30 days (including today):
WHERE YourDateCol >= DATEADD(day, -29, CAST(GETDATE() AS date))
  AND YourDateCol <  DATEADD(day, 1, CAST(GETDATE() AS date));
--Last N days (including today):
DECLARE @N INT = 45; -- Example for last 45 days    
WHERE YourDateCol >= DATEADD(day, -(@N - 1), CAST(GETDATE() AS date))
  AND YourDateCol <  DATEADD(day, 1, CAST(GETDATE() AS date));  
    



