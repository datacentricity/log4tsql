:setvar DbFitDemoDb Log4TSql

USE [$(DbFitDemoDb)];
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[fn_ConcatenateTwoStrings]'), N'IsScalarFunction') = 1
	DROP FUNCTION [dbFitDemo].[fn_ConcatenateTwoStrings];
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[usp_ConcatenateStrings]'), N'IsProcedure') = 1
	DROP PROCEDURE [dbFitDemo].[usp_ConcatenateStrings];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[usp_ConcatenateStrings2]'), N'IsProcedure') = 1
	DROP PROCEDURE [dbFitDemo].[usp_ConcatenateStrings2];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[usp_ExampleDataSet1]'), N'IsProcedure') = 1
	DROP PROCEDURE [dbFitDemo].[usp_ExampleDataSet1];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[usp_ExampleDataSet2]'), N'IsProcedure') = 1
	DROP PROCEDURE [dbFitDemo].[usp_ExampleDataSet2];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[usp_PerformanceTimingTest]'), N'IsProcedure') = 1
	DROP PROCEDURE [dbFitDemo].[usp_PerformanceTimingTest];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[usp_TutorialTestSuiteGetResultSet]'), N'IsProcedure') = 1
	DROP PROCEDURE [dbFitDemo].[usp_TutorialTestSuiteGetResultSet];
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[vwExampleDataSet2]'), N'IsView') = 1
	DROP VIEW [dbFitDemo].[vwExampleDataSet2];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[vwExampleDataSet1]'), N'IsView') = 1
	DROP VIEW [dbFitDemo].[vwExampleDataSet1];
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[Family]'), N'IsUserTable') = 1
	DROP TABLE [dbFitDemo].[Family];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[TestForDefaults]'), N'IsUserTable') = 1
	DROP TABLE [dbFitDemo].[TestForDefaults];
IF OBJECTPROPERTY(OBJECT_ID(N'[dbFitDemo].[Timings]'), N'IsUserTable') = 1
	DROP TABLE [dbFitDemo].[Timings];
GO

RAISERROR ('Dropping schema: [$(DbFitDemoDb)].[dbFitDemo]...', 0, 1) WITH NOWAIT;

IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'dbFitDemo')
	DROP SCHEMA [dbFitDemo];
GO

RAISERROR ('Creating schema: [$(DbFitDemoDb)].[dbFitDemo]...', 0, 1) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dbFitDemo')
	EXEC (N'CREATE SCHEMA [dbFitDemo];');
GO

RAISERROR ('CREATE TABLE: [$(DbFitDemoDb)].[dbFitDemo].[Family] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE TABLE [dbFitDemo].[Family](
	[FamilyID] [int] NULL,
	[TimingID] [int] NULL
) ON [DEFAULT]
GO

RAISERROR ('CREATE TABLE: [$(DbFitDemoDb)].[dbFitDemo].[TestForDefaults] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE TABLE [dbFitDemo].[TestForDefaults](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ValueColumn1] [nvarchar](10) NULL,
	[ValueColumn2] [nvarchar](10) NULL CONSTRAINT DF_TestForDefaults_ValueColumn2 DEFAULT ('Jeff'),
	[ValueColumn3] [nvarchar](10) NULL CONSTRAINT DF_TestForDefaults_ValueColumn3 DEFAULT ('Tim')
) ON [DEFAULT]
GO

RAISERROR ('CREATE TABLE: [$(DbFitDemoDb)].[dbFitDemo].[Timings] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE TABLE [dbFitDemo].[Timings](
	[TimingID] [int] NULL,
	[Timing] [numeric](10, 2) NULL
) ON [DEFAULT]
GO

RAISERROR ('CREATE VIEW: [$(DbFitDemoDb)].[dbFitDemo].[vwExampleDataSet1] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE VIEW [dbFitDemo].[vwExampleDataSet1]
AS
    SELECT  'Propositions' AS 'Name' ,
            20.4 AS 'YTDNetRevenue' ,
            18 AS 'YTDRevenueTarget' ,
            113.33 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            13 AS 'RevenueYOYGrowth' ,
            -2.2 AS 'YTDNNA'
    UNION
    SELECT  'Special Focus' AS 'Name' ,
            18.3 AS 'YTDNetRevenue' ,
            20 AS 'YTDRevenueTarget' ,
            91.5 AS 'YTDRevenue' ,
            'A' AS 'RAG' ,
            43 AS 'RevenueYOYGrowth' ,
            -39.5 AS 'YTDNNA'
    UNION
    SELECT  'Centre' AS 'Name' ,
            19.1 AS 'YTDNetRevenue' ,
            9.0 AS 'YTDRevenueTarget' ,
            212.2 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            76.0 AS 'RevenueYOYGrowth' ,
            1 AS 'YTDNNA'
    UNION
    SELECT  'Regions' AS 'Name' ,
            55.6 AS 'YTDNetRevenue' ,
            70 AS 'YTDRevenueTarget' ,
            79.42857143 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            -8 AS 'RevenueYOYGrowth' ,
            -20.1 AS 'YTDNNA'
    UNION
    SELECT  'London' AS 'Name' ,
            44.2 AS 'YTDNetRevenue' ,
            50 AS 'YTDRevenueTarget' ,
            88.4 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            19 AS 'RevenueYOYGrowth' ,
            -90.4 AS 'YTDNNA'
GO

RAISERROR ('CREATE VIEW: [$(DbFitDemoDb)].[dbFitDemo].[vwExampleDataSet2] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE VIEW [dbFitDemo].[vwExampleDataSet2]
AS
    SELECT  'Propositions' AS 'Name' ,
            20.4 AS 'YTDNetRevenue' ,
            18 AS 'YTDRevenueTarget' ,
            113.33 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            13 AS 'RevenueYOYGrowth' ,
            -2.2 AS 'YTDNNA'
    UNION
    SELECT  'Special Focus' AS 'Name' ,
            18.3 AS 'YTDNetRevenue' ,
            20 AS 'YTDRevenueTarget' ,
            91.5 AS 'YTDRevenue' ,
            'A' AS 'RAG' ,
            43 AS 'RevenueYOYGrowth' ,
            -39.5 AS 'YTDNNA'
    UNION
    SELECT  'Centre' AS 'Name' ,
            20 AS 'YTDNetRevenue' ,
            9.0 AS 'YTDRevenueTarget' ,
            212.2 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            76.0 AS 'RevenueYOYGrowth' ,
            1 AS 'YTDNNA'
    UNION
    SELECT  'Regions' AS 'Name' ,
            55.6 AS 'YTDNetRevenue' ,
            70 AS 'YTDRevenueTarget' ,
            79.42857143 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            -8 AS 'RevenueYOYGrowth' ,
            -20.1 AS 'YTDNNA'
    UNION
    SELECT  'London' AS 'Name' ,
            44.2 AS 'YTDNetRevenue' ,
            50 AS 'YTDRevenueTarget' ,
            88.4 AS 'YTDRevenue' ,
            'R' AS 'RAG' ,
            19 AS 'RevenueYOYGrowth' ,
            -90.4 AS 'YTDNNA'
GO

RAISERROR ('CREATE FUNCTION: [$(DbFitDemoDb)].[dbFitDemo].[fn_ConcatenateTwoStrings] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION [dbFitDemo].[fn_ConcatenateTwoStrings]
(
  @String1 nvarchar(200)
, @String2 nvarchar(200)
)
RETURNS nvarchar(400)
AS
BEGIN
	RETURN ISNULL(@String1,'') + ' ' + ISNULL(@String2,'');
END
GO

RAISERROR ('CREATE PROCEDURE: [$(DbFitDemoDb)].[dbFitDemo].[usp_ConcatenateStrings] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbFitDemo].[usp_ConcatenateStrings]
	@String1 NVARCHAR(200),
	@String2 NVARCHAR(200),
	@Concatenated NVARCHAR(400) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @Concatenated = ISNULL(@String1,'') + ' ' + ISNULL(@String2,'')
END
GO

RAISERROR ('CREATE PROCEDURE: [$(DbFitDemoDb)].[dbFitDemo].[usp_ConcatenateStrings2] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbFitDemo].[usp_ConcatenateStrings2]
	@String1 NVARCHAR(200),
	@String2 NVARCHAR(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ISNULL(@String1,'') + ' ' + ISNULL(@String2,'') Concatenated
END
GO

RAISERROR ('CREATE PROCEDURE: [$(DbFitDemoDb)].[dbFitDemo].[usp_ExampleDataSet1] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbFitDemo].[usp_ExampleDataSet1]
	@Segment	VARCHAR(100),
	@Month		INT,
	@Year		INT
AS
BEGIN

SELECT
'Propositions'	AS 'Name'				,
20.4			AS 'YTDNetRevenue'		,
18				AS 'YTDRevenueTarget'	,
113.33			AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
13				AS 'RevenueYOYGrowth'	,
-2.2			AS 'YTDNNA'				

UNION

SELECT
'Special Focus'	AS 'Name'				,
18.3			AS 'YTDNetRevenue'		,
20				AS 'YTDRevenueTarget'	,
91.5			AS 'YTDRevenue'			,
'A'				AS 'RAG'				,
43				AS 'Revenue YOY Growth'	,
-39.5			AS 'YTDNNA'				

UNION

SELECT

'Centre'		AS 'Name'				,
19.1			AS 'YTDNetRevenue'		,
9.0				AS 'YTDRevenueTarget'	,
212.2			AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
76.0			AS 'RevenueYOYGrowth'	,
1				AS 'YTDNNA'				

UNION

SELECT 
'Regions'		AS 'Name'				,
55.6			AS 'YTDNetRevenue'		,
70				AS 'YTDRevenueTarget'	,
79.42857143		AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
-8				AS 'RevenueYOYGrowth'	,
-20.1			AS 'YTDNNA'				

UNION

SELECT			
'London'		AS 'Name'				,
44.2			AS 'YTDNetRevenue'		,
50				AS 'YTDRevenueTarget'	,
88.4			AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
19				AS 'RevenueYOYGrowth'	,
-90.4			AS 'YTDNNA'				

END
GO

RAISERROR ('CREATE PROCEDURE: [$(DbFitDemoDb)].[dbFitDemo].[usp_ExampleDataSet2] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbFitDemo].[usp_ExampleDataSet2]
	@Segment	VARCHAR(100),
	@Month		INT,
	@Year		INT
AS
BEGIN

SELECT
'Propositions'	AS 'Name'				,
20.4			AS 'YTDNetRevenue'		,
19				AS 'YTDRevenueTarget'	,
113.33			AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
13				AS 'RevenueYOYGrowth'	,
-2.2			AS 'YTDNNA'				
				
UNION			
				
SELECT			
'Special Focus'	AS 'Name'				,
18.3			AS 'YTDNetRevenue'		,
20				AS 'YTDRevenueTarget'	,
91.5			AS 'YTDRevenue'			,
'A'				AS 'RAG'				,
43				AS 'Revenue YOY Growth'	,
-39.5			AS 'YTDNNA'				
				
UNION			
				
SELECT			
				
'Centre'		AS 'Name'				,
19.1			AS 'YTDNetRevenue'		,
9.0				AS 'YTDRevenueTarget'	,
212.2			AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
76.0			AS 'RevenueYOYGrowth'	,
1				AS 'YTDNNA'				
				
UNION			
				
SELECT			
'Regions'		AS 'Name'				,
55.6			AS 'YTDNetRevenue'		,
70				AS 'YTDRevenueTarget'	,
79.42857143		AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
-8				AS 'RevenueYOYGrowth'	,
-20.1			AS 'YTDNNA'				
				
UNION			
				
SELECT			
'London'		AS 'Name'				,
44.2			AS 'YTDNetRevenue'		,
50				AS 'YTDRevenueTarget'	,
88.4			AS 'YTDRevenue'			,
'R'				AS 'RAG'				,
19				AS 'RevenueYOYGrowth'	,
-90.4			AS 'YTDNNA'				

	
	
END

GO

RAISERROR ('CREATE PROCEDURE: [$(DbFitDemoDb)].[dbFitDemo].[usp_PerformanceTimingTest] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbFitDemo].[usp_PerformanceTimingTest]
(
  @DelaySeconds tinyint = NULL
)
AS
BEGIN
	IF @DelaySeconds > 9
		BEGIN
			RAISERROR('@DelaySeconds is %d but cannot be greater than 9', 16, 1, @DelaySeconds);
			RETURN (1);
		END
	ELSE
		BEGIN
			DECLARE @Delay char(8) = '00:00:0' + CAST(ISNULL(@DelaySeconds, 0) AS char(1));

			WAITFOR DELAY @Delay;

			RETURN (0);
		END      
END
GO

RAISERROR ('CREATE PROCEDURE: [$(DbFitDemoDb)].[dbFitDemo].[usp_TutorialTestSuiteGetResultSet] starting...', 0, 1) WITH NOWAIT;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbFitDemo].[usp_TutorialTestSuiteGetResultSet]
(
  @CustomerType char(1)
, @SalesPerson varchar(8) = NULL
, @SomeOtherParameter int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		  CustomerId
		, CustomerName
		, DateOfBirth
		, CustomerType
		, SalesPerson
		, YearToDateSales
	FROM
		(
			--! Use the first result set to define data types and column names
				SELECT
					  CAST(0 AS int)				AS [CustomerId]
					, CAST(NULL AS char(6))			AS [CustomerName]
					, CAST(NULL AS date)			AS [DateOfBirth]
					, CAST('X' AS char(1))			AS [CustomerType]
					, CAST(NULL AS varchar(8))		AS [SalesPerson]
					, CAST(NULL AS decimal(18,2))	AS [YearToDateSales]
			--! List customers with trailing spaces CustomerType = 'F'        
			UNION ALL SELECT 01 , 'Tom   ', '19650423' , 'F' , 'Jan', 150.00  
			UNION ALL SELECT 03 , 'Dick  ', '19660223' , 'F' , 'Sue', 455.00  
			UNION ALL SELECT 05 , 'Harry ', '19710623' , 'F' , 'Sue', 258.00
			--! Now list customers with no trailing spaces in their names CustomerType = 'V'
			UNION ALL SELECT 02 , 'Steven', '19650103' , 'V' , 'Sue', 151.00
			UNION ALL SELECT 04 , 'Edward', '19750213' , 'V' , 'Jan', 552.00
			UNION ALL SELECT 06 , 'Wesley', '19850331' , 'V' , 'Tom', 153.00
			UNION ALL SELECT 08 , 'Justin', '19590423' , 'V' , 'Tom', 654.00
			UNION ALL SELECT 10 , 'Thomas', '19680530' , 'V' , 'Ian', 955.00
			UNION ALL SELECT 12 , 'Adrian', '19720623' , 'V' , 'Kat', 656.00
			UNION ALL SELECT 14 , 'Jeremy', '19810713' , 'V' , 'Sue', 357.00
			UNION ALL SELECT 16 , 'Oliver', '19540823' , 'V' , 'Sue', 258.00
			UNION ALL SELECT 18 , 'Martin', '19650903' , 'V' , 'Sue', 359.00
			UNION ALL SELECT 20 , 'Dennis', '19711013' , 'V' , 'Sue', 150.00
		) AS x  
	WHERE
		--! Interpret "A" as ALL
			CustomerType = COALESCE(NULLIF(@CustomerType, 'A'), CustomerType)
		--! If @SalesPerson is NULL or empty string, return results for all sales persons
		AND SalesPerson = COALESCE(NULLIF(@SalesPerson, ''), SalesPerson)
	ORDER BY
		CustomerName

	SET NOCOUNT OFF;
	RETURN 0;
END
GO

