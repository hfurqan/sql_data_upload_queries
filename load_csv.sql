


USE psx

SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
--SET NUMERIC_ROUNDABORT ON
SET QUOTED_IDENTIFIER ON


DROP TABLE if exists #ticker_staging
DROP TABLE if exists all_tickers

---------------------------------

CREATE TABLE dbo.all_tickers(
  ticker_symbol varchar(32) NOT NULL,
  [Date] datetime2(7) NOT NULL,
  [Open] float NULL,
  High float NULL,
  Low float NULL,
  [close] float NULL,
  Volume float NULL,
  PRIMARY KEY (ticker_symbol, [Date])
);
GO

DECLARE @Path nvarchar(255) = '/home/furqan/PSX';
DECLARE @SQL nvarchar(MAX);
CREATE TABLE #ticker_staging(
  [Date] datetime2(7) NOT NULL,
  [Open] float NULL,
  High float NULL,
  Low float NULL,
  [close] float NULL,
  Volume float NULL
  );

SET @SQL = (SELECT N'
TRUNCATE TABLE #ticker_staging;
BULK INSERT #ticker_staging
    FROM ''' + @Path + N'/' + ticker + N'.csv''
    WITH
    (
    FIRSTROW = 2,
    FIELDTERMINATOR = '','',  --CSV field delimiter
    ROWTERMINATOR = ''\n'',   --Use to shift the control to next row
    TABLOCK
    );
INSERT INTO dbo.all_tickers WITH (TABLOCKX)(
  ticker_symbol,
  [Date],
  [Open],
  High,
  Low,
  [close],
  Volume
) 
SELECT
  ''' + ticker + N''',
  [Date],
  [Open],
  High,
  Low,
  [close],
  Volume
FROM #ticker_staging;'
FROM dbo.symbols
FOR XML PATH(''), TYPE).value('.',N'nvarchar(MAX)');
EXECUTE sp_executesql @SQL;
GO
