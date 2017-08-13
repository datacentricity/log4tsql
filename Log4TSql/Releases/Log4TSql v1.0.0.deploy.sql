--<byline>
--|
--| This build script was generated on 05-NOV-2013 at 14:25 by Greg
--| ...using SQLScriptBuilder v2.2.4 from http://www.data-centric.co.uk
--| Copyright 2006-11 data-centric solutions ltd. All rights reserved.
--|
--</byline>


/**********************************************************************************************************************
**
<plan>
	<ref>Log4TSql Initial Deployment</ref>
	<author>Greg M Lucas</author>
	<date>01-JAN-2011</date>
	<cutoff>31-AUG-2011 23:23:59</cutoff>
	<narrative>Log4TSql Initial Deployment</narrative>
	<includes></includes>
</plan>
**
**
**
** PARAMETERS
** ================================================================================================
** Build Version Number:			0.0.12
** Build Date:						05-NOV-2013
** Target Database:					Log4TSql
**
--go


**
**********************************************************************************************************************/

--! ===============================================================================================
--! SQLCMD Variables
--! ===============================================================================================
:setvar TargetDb "Log4TSql_v1_0_0"
GO

SET NOCOUNT ON;
GO

use master;

if db_id(N'$(TargetDb)') > 0
	drop database [$(TargetDb)];
go

create database [$(TargetDb)]
go

USE [$(TargetDb)];
go

/**************************************************************************************************

(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/

PRINT 'Deployment started at ' + CONVERT(varchar(24), GETDATE(), 121);

RAISERROR('', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;
RAISERROR('Beginning component releases...', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;
RAISERROR('', 0, 1) WITH NOWAIT;
GO

--!-------------------------------------------------------------------------------
--! SCHEMA: [log4]
--!===============================================================================

--!
--! We make sure that the name of the schema used for Log4TSql isn't "dbo" in case
--! someone has done a search & replace on the release script to move the framework
--! into the default schema to comply with some corporate rule
--!
IF 'log4' != 'dbo' AND SCHEMA_ID('log4') IS NULL
	EXEC sp_executesql N'CREATE SCHEMA [log4] AUTHORIZATION [dbo]';
GO


/**********************************************************************************************************************
**
<plan>
	<ref>Log4TSql Tables - Release</ref>
	<author>Greg M. Lucas</author>
	<date>01-JAN-2012</date>
	<narrative>Log4TSql Tables - Release</narrative>
	<includes></includes>
</plan>
**
**********************************************************************************************************************/

RAISERROR('', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;
RAISERROR('Now deploying Log4TSql Tables...', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;

SET NOCOUNT ON;
GO

IF OBJECT_ID(N'[log4].[FK_Journal_Severity]', 'F') > 0
	ALTER TABLE [log4].[Journal] DROP CONSTRAINT [FK_Journal_Severity]
GO

IF OBJECT_ID(N'[log4].[FK_Journal_Exception]', 'F') > 0
	ALTER TABLE [log4].[Journal] DROP CONSTRAINT [FK_Journal_Exception]
GO

IF OBJECT_ID(N'[log4].[FK_JournalDetail_Journal]', 'F') > 0
	ALTER TABLE [log4].[JournalDetail] DROP CONSTRAINT [FK_JournalDetail_Journal]
GO


IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[JournalControl]'), N'IsUserTable') = 1
	DROP TABLE [log4].[JournalControl];
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[JournalDetail]'), N'IsUserTable') = 1
	DROP TABLE [log4].[JournalDetail]
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[Journal]'), N'IsUserTable') = 1
	DROP TABLE [log4].[Journal]
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[Severity]'), N'IsUserTable') = 1
	DROP TABLE [log4].[Severity]
GO

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[Exception]'), N'IsUserTable') = 1
	DROP TABLE [log4].[Exception];
GO



CREATE TABLE [log4].[Exception] (
    [ExceptionId]       INT            IDENTITY (1, 1) NOT NULL,
    [UtcDate]           DATETIME       CONSTRAINT [DF_Exception_UtcDate] DEFAULT (getutcdate()) NOT NULL,
    [SystemDate]        DATETIME       CONSTRAINT [DF_Exception_SystemDate] DEFAULT (getdate()) NOT NULL,
    [ErrorContext]      NVARCHAR (512) NOT NULL,
    [ErrorNumber]       INT            NOT NULL,
    [ErrorSeverity]     INT            NOT NULL,
    [ErrorState]        INT            NOT NULL,
    [ErrorProcedure]    NVARCHAR (128) NOT NULL,
    [ErrorLine]         INT            NOT NULL,
    [ErrorMessage]      NVARCHAR (MAX) NOT NULL,
    [SessionId]         INT            NOT NULL,
    [ServerName]        NVARCHAR (128) NOT NULL,
    [DatabaseName]      NVARCHAR (128) NOT NULL,
    [HostName]          NVARCHAR (128) NOT NULL,
    [ProgramName]       NVARCHAR (128) NOT NULL,
    [NTDomain]          NVARCHAR (128) NOT NULL,
    [NTUsername]        NVARCHAR (128) NOT NULL,
    [LoginName]         NVARCHAR (128) NOT NULL,
    [OriginalLoginName] NVARCHAR (128) NOT NULL,
    [SessionLoginTime]  DATETIME       NULL,
    CONSTRAINT [PK_Exception] PRIMARY KEY NONCLUSTERED ([ExceptionId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE CLUSTERED INDEX [CI_Exception_UtcDate]
    ON [log4].[Exception]([UtcDate] ASC) WITH (FILLFACTOR = 100);

GO


CREATE TABLE [log4].[Severity] (
    [SeverityId]   INT           NOT NULL,
    [SeverityName] VARCHAR (128) NOT NULL,
    CONSTRAINT [PK_Severity] PRIMARY KEY NONCLUSTERED ([SeverityId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [UQ_Severity_SeverityName] UNIQUE NONCLUSTERED ([SeverityName] ASC) WITH (FILLFACTOR = 100)
);

GO

SET NOCOUNT ON
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 1
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        1
      , 'Showstopper/Critical Failure'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Showstopper/Critical Failure'
    WHERE
        [SeverityId] = 1
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 2
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        2
      , 'Severe Failure'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Severe Failure'
    WHERE
        [SeverityId] = 2
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 4
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        4
      , 'Major Failure'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Major Failure'
    WHERE
        [SeverityId] = 4
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 8
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        8
      , 'Moderate Failure'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Moderate Failure'
    WHERE
        [SeverityId] = 8
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 16
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        16
      , 'Minor Failure'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Minor Failure'
    WHERE
        [SeverityId] = 16
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 32
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        32
      , 'Concurrency Violation'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Concurrency Violation'
    WHERE
        [SeverityId] = 32
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 64
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        64
      , 'Reserved for future Use 1'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Reserved for future Use 1'
    WHERE
        [SeverityId] = 64
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 128
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        128
      , 'Reserved for future Use 2'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Reserved for future Use 2'
    WHERE
        [SeverityId] = 128
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 256
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        256
      , 'Informational'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Informational'
    WHERE
        [SeverityId] = 256
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 512
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        512
      , 'Success'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Success'
    WHERE
        [SeverityId] = 512
GO

IF NOT EXISTS
    (
        SELECT 1 FROM [log4].[Severity] WHERE [SeverityId] = 1024
    )
  INSERT INTO [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  VALUES
      (
        1024
      , 'Debug'
      )
ELSE
    UPDATE
        [log4].[Severity]
    SET
          [SeverityName] = 'Debug'
    WHERE
        [SeverityId] = 1024
GO


SET NOCOUNT ON
GO



CREATE TABLE [log4].[JournalControl] (
    [ModuleName]  VARCHAR (255) NOT NULL,
    [OnOffSwitch] VARCHAR (3)   NOT NULL,
    CONSTRAINT [PK_JournalControl] PRIMARY KEY NONCLUSTERED ([ModuleName] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_JournalControl_OnOffSwitch] CHECK ([OnOffSwitch]='OFF' OR [OnOffSwitch]='ON')
);


GO
CREATE CLUSTERED INDEX [CI_JournalControl_ModuleName]
    ON [log4].[JournalControl]([ModuleName] ASC) WITH (FILLFACTOR = 100);

GO


CREATE TABLE [log4].[Journal] (
    [JournalId]         INT            IDENTITY (1, 1) NOT NULL,
    [UtcDate]           DATETIME       CONSTRAINT [DF_Journal_UtcDate] DEFAULT (getutcdate()) NOT NULL,
    [SystemDate]        DATETIME       CONSTRAINT [DF_Journal_SystemDate] DEFAULT (getdate()) NOT NULL,
    [Task]              VARCHAR (128)  CONSTRAINT [DF_Journal_Task] DEFAULT ('') NOT NULL,
    [FunctionName]      VARCHAR (256)  NOT NULL,
    [StepInFunction]    VARCHAR (128)  NOT NULL,
    [MessageText]       VARCHAR (512)  NOT NULL,
    [SeverityId]        INT            NOT NULL,
    [ExceptionId]       INT            NULL,
    [SessionId]         INT            NOT NULL,
    [ServerName]        NVARCHAR (128) NOT NULL,
    [DatabaseName]      NVARCHAR (128) NOT NULL,
    [HostName]          NVARCHAR (128) NULL,
    [ProgramName]       NVARCHAR (128) NULL,
    [NTDomain]          NVARCHAR (128) NULL,
    [NTUsername]        NVARCHAR (128) NULL,
    [LoginName]         NVARCHAR (128) NULL,
    [OriginalLoginName] NVARCHAR (128) NULL,
    [SessionLoginTime]  DATETIME       NULL,
    CONSTRAINT [PK_Journal] PRIMARY KEY NONCLUSTERED ([JournalId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Journal_Severity] FOREIGN KEY ([SeverityId]) REFERENCES [log4].[Severity] ([SeverityId]),
    CONSTRAINT [FK_Journal_Exception] FOREIGN KEY ([ExceptionId]) REFERENCES [log4].[Exception] ([ExceptionId])
);

GO
CREATE CLUSTERED INDEX [CI_Journal_SystemDate]
    ON [log4].[Journal]([SystemDate] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NCI_Journal_FunctionName_Severity]
    ON [log4].[Journal]([FunctionName] ASC, [SeverityId] ASC) WITH (FILLFACTOR = 80);

GO

CREATE TABLE [log4].[JournalDetail] (
    [JournalId] INT           NOT NULL,
    [ExtraInfo] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_JournalDetail] PRIMARY KEY NONCLUSTERED ([JournalId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_JournalDetail_Journal] FOREIGN KEY ([JournalId]) REFERENCES [log4].[Journal] ([JournalId]) ON DELETE CASCADE
);

GO



SET NOCOUNT OFF;
GO

/**********************************************************************************************************************
**
<plan>
	<ref>Log4TSql Modules - Release</ref>
	<author>Greg M. Lucas</author>
	<date>01-JAN-2012</date>
	<narrative>Log4TSql Modules - Release</narrative>
	<includes></includes>
</plan>
**
**********************************************************************************************************************/

RAISERROR('', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;
RAISERROR('Now deploying Log4TSql Modules...', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;

SET NOCOUNT ON;
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[FormatElapsedTime]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[FormatElapsedTime]'), N'IsScalarFunction') = 1
	DROP FUNCTION [log4].[FormatElapsedTime];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE FUNCTION [log4].[FormatElapsedTime]
(
  @StartTime                      datetime
, @EndTime                        datetime  = NULL
, @ShowMillisecsIfUnderNumSecs    tinyint   = NULL
)

RETURNS varchar  (  48 )

AS

--<CommentHeader>
/**************************************************************************************************

Properties
==========
FUNCTION NAME:      [log4].[FormatElapsedTime]
DESCRIPTION:        Returns a string describing the time elapsed between start and end time
DATE OF ORIGIN:		16-FEB-2007
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:         Various
DEPENDENCIES:       None

Additional Notes
================
Builds a string that looks like this: "0 hr(s) 1 min(s) and 22 sec(s)" or "1345 milliseconds"

Revision history
==================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		==============================================================
16-FEB-2007		GML		v0.0.2		Created
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/
--</CommentHeader>

BEGIN
	DECLARE	  @time                     int
			, @hrs                      int
			, @mins                     int
			, @secs                     int
			, @msecs                    int
			, @Duration                 varchar   (   48 )

	IF @StartTime IS NULL AND @EndTime IS NULL
		SET @Duration = 'Start and End Times are both NULL'
	ELSE IF @StartTime IS NULL
		SET @Duration = 'Start Time is NULL'
	ELSE
		BEGIN
			IF @EndTime IS NULL SET @EndTime = GETDATE()

			SET @time = DATEDIFF(ss, @StartTime, @EndTime)

			IF @time > ISNULL(@ShowMillisecsIfUnderNumSecs, 5)
				BEGIN
					SET @hrs        = @time / 3600
					SET @mins       = (@time % 3600) / 60
					SET @secs       = (@time % 3600) % 60
					SET @Duration   = CASE
										WHEN @hrs = 0 THEN ''
										WHEN @hrs = 1 THEN CAST(@hrs AS varchar) + ' hr, '
										ELSE CAST(@hrs AS varchar) + ' hrs, '
									  END
									+ CASE
										WHEN @mins = 1 THEN CAST(@mins AS varchar) + ' min'
										ELSE CAST(@mins AS varchar) + ' mins'
									  END
									+ ' and '
									+ CASE
										WHEN @secs = 1 THEN CAST(@secs AS varchar) + ' sec'
										ELSE CAST(@secs AS varchar) + ' secs'
									  END
				END
			ELSE
				BEGIN
					SET @msecs      = DATEDIFF(ms, @StartTime, @EndTime)
					SET @Duration   = CAST(@msecs AS varchar) + ' milliseconds'
				END
		END

	RETURN @Duration
END



GO
GRANT EXECUTE
    ON OBJECT::[log4].[FormatElapsedTime] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns a string describing the time elapsed between start and end time', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'FUNCTION', @level1name = N'FormatElapsedTime';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[FormatElapsedTime] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[GetJournalControl]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[GetJournalControl]'), N'IsScalarFunction') = 1
	DROP FUNCTION [log4].[GetJournalControl];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE FUNCTION [log4].[GetJournalControl]
(
  @ModuleName		varchar	(  255 )
, @GroupName		varchar	(  255 )
)

RETURNS varchar		(  3 )

AS

--<CommentHeader>
/**************************************************************************************************

Properties
==========
FUNCTION NAME:      [log4].[GetJournalControl]
DESCRIPTION:		Returns the ON/OFF value for the specified Journal Name, or Group Name if
					Module not found or the system default if neither is found
DATE OF ORIGIN:		15-APR-2008
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:         Various
DEPENDENCIES:       None

Additional Notes
================
Builds a string that looks like this: "0 hr(s) 1 min(s) and 22 sec(s)" or "1345 milliseconds"

Revision history
==================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		==============================================================
15-APR-2008		GML		v0.0.3		Created
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/
--</CommentHeader>

BEGIN
	RETURN
		(
			SELECT
				TOP 1 OnOffSwitch
			FROM
				(
						SELECT
							  OnOffSwitch
							, 1 AS [Precedence]
						FROM
							[log4].[JournalControl]
						WHERE
							ModuleName = 'SYSTEM_OVERRIDE'
						AND
							OnOffSwitch = 'OFF' -- only care about the override when it's OFF
					UNION
						SELECT
							  OnOffSwitch
							, 10 AS [Precedence]
						FROM
							[log4].[JournalControl]
						WHERE
							ModuleName = @ModuleName
					UNION
						SELECT
							  OnOffSwitch
							, 100 AS [Precedence]
						FROM
							[log4].[JournalControl]
						WHERE
							ModuleName = @GroupName
					UNION
						SELECT
							  OnOffSwitch
							, 200 AS [Precedence]
						FROM
							[log4].[JournalControl]
						WHERE
							ModuleName = 'SYSTEM_DEFAULT'
					UNION
						SELECT
							  'OFF'		AS [OnOffSwitch]
							, 300		AS [Precedence]
				) AS [x]
			ORDER BY
				[Precedence] ASC
		)
END

GO
GRANT EXECUTE
    ON OBJECT::[log4].[GetJournalControl] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns the ON/OFF value for the specified Journal Name, or Group Name if Module not found or the system default if neither is found', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'FUNCTION', @level1name = N'GetJournalControl';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[GetJournalControl] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO


--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[SessionInfoOutput]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[SessionInfoOutput]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[SessionInfoOutput];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[SessionInfoOutput]
(
  @SessionId          int
, @HostName           nvarchar ( 128 ) = NULL  OUT
, @ProgramName        nvarchar ( 128 ) = NULL  OUT
, @NTDomain           nvarchar ( 128 ) = NULL  OUT
, @NTUsername         nvarchar ( 128 ) = NULL  OUT
, @LoginName          nvarchar ( 128 ) = NULL  OUT
, @OriginalLoginName  nvarchar ( 128 ) = NULL  OUT
, @SessionLoginTime   datetime         = NULL  OUT
)

AS

--<CommentHeader>
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:  SessionInfoOutput
DESCRIPTION:     Outputs session info from master.sys.dm_exec_sessions for the current @@SPID
DATE OF ORIGIN:  15-APR-2008
ORIGINAL AUTHOR: Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:      13-MAR-2012
BUILD VERSION:   0.0.10
DEPENDANTS:      log4.ExceptionHandler
                 log4.JournalWriter
DEPENDENCIES:    Called functions

Returns
=====================================================================================================================
@@ERROR - always zero on success

Additional Notes
=====================================================================================================================


Revision history
=====================================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		=================================================================================
15-APR-2008		GML		vX.Y.z		Created
------------	------	-------		---------------------------------------------------------------------------------


=====================================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**********************************************************************************************************************/
--</CommentHeader>

BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		SELECT
			  @HostName				= s.[host_name]
			, @ProgramName			= s.[program_name]
			, @NTDomain				= s.nt_domain
			, @NTUsername			= s.nt_user_name
			, @LoginName			= s.login_name
			, @OriginalLoginName	= s.original_login_name
			, @SessionLoginTime		= s.login_time
		FROM
			master.sys.dm_exec_sessions AS [s] WITH (NOLOCK)
		WHERE
			s.session_id = @SessionId
	END TRY
	BEGIN CATCH
		--! Make sure we return non-null values
		SET @SessionId			= 0
		SET @HostName			= ''
		SET @ProgramName		= 'log4.SessionInfoOutput Error!'
		SET @NTDomain			= ''
		SET @NTUsername			= ''
		SET @LoginName			= 'log4.SessionInfoOutput Error!'
		SET @OriginalLoginName	= ''

		DECLARE @context nvarchar(512); SET @context = 'log4.SessionInfoOutput failed to retrieve session info';

		--! Only rollback if we have an uncommitable transaction
		IF (XACT_STATE() = -1)
		OR (@@TRANCOUNT > 0 AND XACT_STATE() != 1)
			BEGIN
				ROLLBACK TRAN;
				SET @context = @context + ' (Forced rolled back of all changes due to uncommitable transaction)';
			END

		--! Log this error directly
		--! Don't call ExceptionHandler in case we get another
		--! SessionInfoOutput error and and up in a never-ending loop)
		INSERT [log4].[Exception]
		(
		  [ErrorContext]
		, [ErrorNumber]
		, [ErrorSeverity]
		, [ErrorState]
		, [ErrorProcedure]
		, [ErrorLine]
		, [ErrorMessage]
		, [SessionId]
		, [ServerName]
		, [DatabaseName]
		)
		SELECT
			  @context
			, ERROR_NUMBER()
			, ERROR_SEVERITY()
			, ERROR_STATE()
			, ERROR_PROCEDURE()
			, ERROR_LINE()
			, ERROR_MESSAGE()
			, @@SPID
			, @@SERVERNAME
			, DB_NAME()
	END CATCH

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE
    ON OBJECT::[log4].[SessionInfoOutput] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Outputs session info from master.sys.dm_exec_sessions for the current @@SPID', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'SessionInfoOutput';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[SessionInfoOutput] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[ExceptionHandler]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[ExceptionHandler]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[ExceptionHandler];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[ExceptionHandler]
(
  @ErrorContext		nvarchar	(  512 )	= NULL
, @DatabaseName		nvarchar	(  128 )	= NULL	OUT
, @ErrorProcedure	nvarchar	(  128 )	= NULL	OUT
, @ErrorNumber		int						= NULL	OUT
, @ErrorSeverity	int						= NULL	OUT
, @ErrorState		int						= NULL	OUT
, @ErrorLine		int						= NULL	OUT
, @ErrorMessage		nvarchar	( 4000 )	= NULL	OUT
, @ReturnMessage	nvarchar	( 1000 )	= NULL	OUT
, @ExceptionId		int						= NULL	OUT
)
AS

--<CommentHeader>
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		log4.ExceptionHandler
DESCRIPTION:		Returns error info as output parameters and writes info to Exception table
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:			Various
DEPENDENCIES:		log4.SessionInfoOutput

Outputs
=====================================================================================================================
Outputs all values collected within the CATCH block plus a formatted error message built from context and error msg

Returns
=====================================================================================================================
- @@ERROR - always zero on success


Additional Notes
=====================================================================================================================
-

Revision history
=====================================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		=================================================================================
01-DEC-2006		GML		v0.0.1		Created
------------	------	-------		---------------------------------------------------------------------------------
15-APR-2008		GML		v0.0.3		Now utilises SessionInfoOutput sproc for session values
------------	------	-------		---------------------------------------------------------------------------------

=====================================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**********************************************************************************************************************/
--</CommentHeader>

BEGIN
	SET NOCOUNT ON;

	SET @ErrorContext		= COALESCE(@ErrorContext, '');
	SET @DatabaseName		= COALESCE(@DatabaseName, DB_NAME());
	SET @ErrorProcedure		= COALESCE(NULLIF(@ErrorProcedure, ''), ERROR_PROCEDURE(), '');
	SET @ErrorNumber		= COALESCE(ERROR_NUMBER(), 0);
	SET @ErrorSeverity		= COALESCE(ERROR_SEVERITY(), 0);
	SET @ErrorState			= COALESCE(ERROR_STATE(), 0);
	SET @ErrorLine			= COALESCE(ERROR_LINE(), 0);
	SET @ErrorMessage		= COALESCE(ERROR_MESSAGE()
								, 'ERROR_MESSAGE() Not Found for @@ERROR: '
									+ COALESCE(CAST(ERROR_NUMBER() AS varchar(16)), 'NULL'));

	--!
	--! Generate a detailed, nicely formatted error message to return to the caller
	--!
	DECLARE @context nvarchar(512); SET @context = COALESCE(NULLIF(@ErrorContext, '') + ' due to ', 'ERROR! ');
	SET @ReturnMessage	= @context
						+ CASE
							WHEN LEN(ERROR_MESSAGE()) > (994 - LEN(@context))
								THEN '"' + SUBSTRING(@ErrorMessage, 1, (994 - LEN(@context))) + '..."'
							ELSE
								'"' + @ErrorMessage + '"'
						  END;

	--!
	--! Session variables (keep it SQL2005 compatible)
	--!
	DECLARE @SessionId	int					; SET @SessionId		= @@SPID;
	DECLARE @ServerName	nvarchar	( 128 )	; SET @ServerName		= @@SERVERNAME;

	--!
	--! log4.SessionInfoOutput variables
	--!
	DECLARE   @HostName				nvarchar	( 128 )
			, @ProgramName			nvarchar	( 128 )
			, @NTDomain				nvarchar	( 128 )
			, @NTUsername			nvarchar	( 128 )
			, @LoginName			nvarchar	( 128 )
			, @OriginalLoginName	nvarchar	( 128 )
			, @SessionLoginTime		datetime

	--! Working variables
	DECLARE @tblExceptionId         table	(ExceptionId int NOT NULL UNIQUE);

	--!
	--! Get the details for the current session
	--!
	EXEC log4.SessionInfoOutput
			  @SessionId			= @SessionId
			, @HostName				= @HostName				OUT
			, @ProgramName			= @ProgramName			OUT
			, @NTDomain				= @NTDomain				OUT
			, @NTUsername			= @NTUsername			OUT
			, @LoginName			= @LoginName			OUT
			, @OriginalLoginName	= @OriginalLoginName	OUT
			, @SessionLoginTime		= @SessionLoginTime		OUT

	--!
	--! Record what we have
	--!
	INSERT [log4].[Exception]
	(
	  [ErrorContext]
	, [ErrorNumber]
	, [ErrorSeverity]
	, [ErrorState]
	, [ErrorProcedure]
	, [ErrorLine]
	, [ErrorMessage]
	, [SessionId]
	, [ServerName]
	, [DatabaseName]
	, [HostName]
	, [ProgramName]
	, [NTDomain]
	, [NTUsername]
	, [LoginName]
	, [OriginalLoginName]
	, [SessionLoginTime]
	)
	OUTPUT inserted.ExceptionId INTO @tblExceptionId
	VALUES
	(
	  @ErrorContext
	, @ErrorNumber
	, @ErrorSeverity
	, @ErrorState
	, @ErrorProcedure
	, @ErrorLine
	, @ErrorMessage
	, @SessionId
	, @ServerName
	, @DatabaseName
	, @HostName
	, @ProgramName
	, @NTDomain
	, @NTUsername
	, @LoginName
	, @OriginalLoginName
	, @SessionLoginTime
	);

	SELECT @ExceptionId = ExceptionId FROM @tblExceptionId;

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	SET NOCOUNT OFF;

	RETURN;
END

GO
GRANT EXECUTE
    ON OBJECT::[log4].[ExceptionHandler] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns error info as output parameters and writes info to Exception table', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'ExceptionHandler';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[ExceptionHandler] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[ExceptionReader]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[ExceptionReader]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[ExceptionReader];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[ExceptionReader]
(
  @StartDate			datetime				= NULL
, @EndDate				datetime				= NULL
, @TimeZoneOffset		smallint				= NULL
, @ErrorProcedure		varchar		(  256 )	= NULL
, @ProcedureSearchType	tinyint					= NULL
, @ErrorMessage			varchar		(  512 )	= NULL
, @MessageSearchType	tinyint					= NULL
, @ResultSetSize		int						= NULL
)

AS

/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4].[ExceptionReader]
DESCRIPTION:		Returns all Exceptions matching the specified search criteria
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			29-AUG-2011
BUILD VERSION:		0.0.6
DEPENDANTS:			None
DEPENDENCIES:		None

Returns
=======
@@ERROR - always zero on success

Additional Notes
================

Function and Message Search Types:

0 = Exclude from Search
1 = Begins With
2 = Ends With
3 = Contains
4 = Exact Match

Revision history
==================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		==============================================================
01-DEC-2006		GML		v0.0.1		Created
------------	------	-------		--------------------------------------------------------------
03-MAY-2011		GML		v0.0.4		Added @TimeZoneOffset for ease of use in other timezones
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/

BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	--! Working variables
	DECLARE	  @Error            int
			, @RowCount         int

	SET @Error 			= 0
	SET @TimeZoneOffset	= COALESCE(@TimeZoneOffset, 0)

	--!
	--! Format the Function search string according to the required search criteria
	--!
	IF LEN(ISNULL(@ErrorProcedure, '')) = 0 OR @ProcedureSearchType = 0
		SET @ErrorProcedure = '%'
	ELSE IF LEN(@ErrorProcedure) < 256
		BEGIN
			IF @ProcedureSearchType & 1 = 1 AND SUBSTRING(REVERSE(@ErrorProcedure), 1, 1) != '%'
				SET @ErrorProcedure = @ErrorProcedure + '%'

			IF @ProcedureSearchType & 2 = 2 AND SUBSTRING(@ErrorProcedure, 1, 1) != '%'
				SET @ErrorProcedure = '%' + @ErrorProcedure

			--! If @ProcedureSearchType = 4, do nothing as we want an exact match
		END

	--!
	--! Format the Message search string according to the required search criteria
	--!
	IF LEN(ISNULL(@ErrorMessage, '')) = 0 OR @MessageSearchType = 0
		SET @ErrorMessage = '%'
	ELSE IF LEN(@ErrorMessage) < 512
		BEGIN
			IF @MessageSearchType & 1 = 1 AND SUBSTRING(REVERSE(@ErrorMessage), 1, 1) != '%'
				SET @ErrorMessage = @ErrorMessage + '%'

			IF @MessageSearchType & 2 = 2 AND SUBSTRING(@ErrorMessage, 1, 1) != '%'
				SET @ErrorMessage = '%' + @ErrorMessage

			--! If @MessageSearchType = 4, do nothing as we want an exact match
		END

	--!
	--! If @ResultSetSize is invalid, just return the last 100 rows
	--!
	IF ISNULL(@ResultSetSize, -1) < 1 SET @ResultSetSize = 100
	IF @StartDate IS NULL SET @StartDate = CONVERT(datetime, CONVERT(char(8), DATEADD(day, -10, GETDATE())) + ' 00:00:00', 112)
	IF @EndDate IS NULL SET @EndDate = CONVERT(datetime, CONVERT(char(8), GETDATE(), 112) + ' 23:59:59', 112)

	--! Reverse any time zone offset so we are searching on system time
	SET @StartDate	= DATEADD(hour, @TimeZoneOffset * -1, @StartDate)
	SET @EndDate	= DATEADD(hour, @TimeZoneOffset * -1, @EndDate)

	--!
	--! Return the required results
	--!
	SELECT TOP (@ResultSetSize)
		  ExceptionId
		, DATEADD(hour, @TimeZoneOffset, SystemDate)						AS [LocalTime]
		---------------------------------------------------------------------------------------------------
		, ErrorNumber
		, ErrorContext
		, REPLACE(REPLACE(ErrorMessage, CHAR(13), '  '), CHAR(10), '  ')	AS [ErrorMessage]
		, ErrorSeverity
		, ErrorState
		, ErrorProcedure
		, ErrorLine
		---------------------------------------------------------------------------------------------------
		, SystemDate
		, [SessionId]
		, [ProgramName]
		, [NTDomain]
		, [NTUsername]
		, [LoginName]
	FROM
		[log4].[Exception]
	WHERE
		SystemDate BETWEEN @StartDate AND @EndDate
	AND
		ErrorProcedure LIKE @ErrorProcedure
	AND
		ErrorMessage LIKE @ErrorMessage
	ORDER BY
		ExceptionId DESC

	SELECT @Error = @@ERROR, @RowCount = @@ROWCOUNT

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	SET NOCOUNT OFF

	RETURN(@Error)

END



GO
GRANT EXECUTE
    ON OBJECT::[log4].[ExceptionReader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns all Exceptions matching the specified search criteria', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'ExceptionReader';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[ExceptionReader] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[JournalWriter]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[JournalWriter]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[JournalWriter];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[JournalWriter]
(
  @FunctionName			varchar		(  256 )
, @MessageText			varchar		(  512 )
, @ExtraInfo			varchar		(  max )	= NULL
, @DatabaseName			nvarchar	(  128 )	= NULL
, @Task					nvarchar	(  128 )	= NULL
, @StepInFunction		varchar		(  128 )	= NULL
, @Severity				smallint				= NULL
, @ExceptionId			int						= NULL
, @JournalId			int						= NULL OUT
)

AS

/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4].[JournalWriter]
DESCRIPTION:		Adds a journal entry summarising task progress, completion or failure msgs etc.
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:			Various
DEPENDENCIES:		[log4].[SessionInfoOutput]
					[log4].[ExceptionHandler]

Returns
=======
@@ERROR - always zero on success

Additional Notes
================
Possible options for @Severity

   1 -- Showstopper/Critical Failure
   2 -- Severe Failure
   4 -- Major Failure
   8 -- Moderate Failure
  16 -- Minor Failure
  32 -- Concurrency Violation
  64 -- Reserved for future Use
 128 -- Reserved for future Use
 256 -- Informational
 512 -- Success
1024 -- Debug
2048 -- Reserved for future Use
4096 -- Reserved for future Use



Revision history
==================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		==============================================================
01-DEC-2006		GML		v0.0.1		Created
------------	------	-------		--------------------------------------------------------------
15-APR-2008		GML		v0.0.3		Now utilises [log4].[SessionInfoOutput] sproc for session values
------------	------	-------		--------------------------------------------------------------
03-MAY-2011		GML		v0.0.4		Added support for JournalDetail table
------------	------	-------		--------------------------------------------------------------
28-AUG-2011		GML		v0.0.6		Added support for ExceptionId and Task columns
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/

BEGIN
	SET NOCOUNT ON

	DECLARE @Error int; SET @Error = 0;

	--!
	--! Define input defaults
	--!
	SET @DatabaseName	= COALESCE(@DatabaseName, DB_NAME())
	SET @FunctionName	= COALESCE(@FunctionName, '')
	SET @StepInFunction	= COALESCE(@StepInFunction, '')
	SET @MessageText	= COALESCE(@MessageText, '')
	SET @ExtraInfo		= COALESCE(@ExtraInfo, '')
	SET @Task			= COALESCE(@Task, '')

	--! Make sure the supplied severity fits our bitmask model
	IF ISNULL(@Severity, 0) NOT IN (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096)
		BEGIN
			SET @ExtraInfo  = COALESCE(NULLIF(@ExtraInfo, '') + CHAR(13), '')
							+ '(Severity value: ' + COALESCE(CAST(@Severity AS varchar), 'NULL') + ' is invalid so using 256)'
			SET @Severity   = 256 -- Informational
		END

	--!
	--! Session variables (keep it SQL2005 compatible)
	--!
	DECLARE @SessionId	int					; SET @SessionId		= @@SPID;
	DECLARE @ServerName	nvarchar	( 128 )	; SET @ServerName		= @@SERVERNAME;

	--!
	--! log4.SessionInfoOutput variables
	--!
	DECLARE   @HostName				nvarchar	( 128 )
			, @ProgramName			nvarchar	( 128 )
			, @NTDomain				nvarchar	( 128 )
			, @NTUsername			nvarchar	( 128 )
			, @LoginName			nvarchar	( 128 )
			, @OriginalLoginName	nvarchar	( 128 )
			, @SessionLoginTime		datetime


	--!
	--! Get the details for the current session
	--!
	EXEC log4.SessionInfoOutput
			  @SessionId			= @SessionId
			, @HostName				= @HostName				OUT
			, @ProgramName			= @ProgramName			OUT
			, @NTDomain				= @NTDomain				OUT
			, @NTUsername			= @NTUsername			OUT
			, @LoginName			= @LoginName			OUT
			, @OriginalLoginName	= @OriginalLoginName	OUT
			, @SessionLoginTime		= @SessionLoginTime		OUT

	--! Working variables
	DECLARE @tblJournalId table	(JournalId int NOT NULL UNIQUE);

	BEGIN TRY
		INSERT [log4].[Journal]
		(
		  [Task]
		, [FunctionName]
		, [StepInFunction]
		, [MessageText]
		, [SeverityId]
		, [ExceptionId]
		------------------------
		, [SessionId]
		, [ServerName]
		, [DatabaseName]
		, [HostName]
		, [ProgramName]
		, [NTDomain]
		, [NTUsername]
		, [LoginName]
		, [OriginalLoginName]
		, [SessionLoginTime]
		)
	OUTPUT inserted.JournalId INTO @tblJournalId
	VALUES
		(
		  @Task
		, @FunctionName
		, @StepInFunction
		, @MessageText
		, @Severity
		, @ExceptionId
		------------------------
		, @SessionId
		, @ServerName
		, @DatabaseName
		, @HostName
		, @ProgramName
		, @NTDomain
		, @NTUsername
		, @LoginName
		, @OriginalLoginName
		, @SessionLoginTime
		)

		SELECT @JournalId = JournalId FROM @tblJournalId;

		INSERT [log4].[JournalDetail]
		(
		  JournalId
		, ExtraInfo
		)
		VALUES
		(
		  @JournalId
		, @ExtraInfo
		)

	END TRY
	BEGIN CATCH
		--!
		--! If we have an uncommitable transaction (XACT_STATE() = -1), if we hit a deadlock
		--! or if @@TRANCOUNT > 0 AND XACT_STATE() != 1, we HAVE to roll back.
		--! Otherwise, leaving it to the calling process
		--!
		IF (@@TRANCOUNT > 0 AND XACT_STATE() != 1) OR (XACT_STATE() = -1) OR (ERROR_NUMBER() = 1205)
			BEGIN
				ROLLBACK TRAN

				SET @MessageText    = 'Failed to write journal entry: '
									+ CASE
										WHEN LEN(@MessageText) > 440
											THEN '"' + SUBSTRING(@MessageText, 1, 440) + '..."'
										ELSE
											COALESCE('"' + @MessageText + '"', 'NULL')
										END
									+ ' (Forced roll back of all changes)'
			END
		ELSE
			BEGIN
				SET @MessageText    = 'Failed to write journal entry: '
									+ CASE
										WHEN LEN(@MessageText) > 475
											THEN '"' + SUBSTRING(@MessageText, 1, 475) + '..."'
										ELSE
											COALESCE('"' + @MessageText + '"', 'NULL')
										END
			END

		--! Record any failure info
		EXEC [log4].[ExceptionHandler]
				  @ErrorContext = @MessageText
				, @ErrorNumber  = @Error OUT
	END CATCH

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	SET NOCOUNT OFF

	RETURN(@Error)

END



GO
GRANT EXECUTE
    ON OBJECT::[log4].[JournalWriter] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Adds a journal entry summarising task progress, completion or failure msgs etc.', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'JournalWriter';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[JournalWriter] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[PrintString]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[PrintString]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[PrintString];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[PrintString]
(
  @InputString		nvarchar(max)	= NULL
, @MaxPrintLength	int				= 4000
)

AS

--<CommentHeader>
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		[log4].[PrintString]
DESCRIPTION:		Prints the supplied string respecting all line feeds and/or carriage returns except where no
					line feeds are found, in which case the output is printed in user-specified lengths
DATE OF ORIGIN:		05-NOV-2011
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:			None
DEPENDENCIES:		None

Inputs
======
@InputString - optional, the string to print
@MaxPrintLength - Max length of string to print before inserting an unnatural break

Outputs
=======
None

Returns
=======
NULL

Additional Notes
================

Revision history
=====================================================================================================================
ChangeDate    Author   Version  Narrative
============  =======  =======  =====================================================================================
05-NOV-2011   GML      v0.0.8   Created
------------  -------  -------  -------------------------------------------------------------------------------------
13-MAR-2012   GML      v0.0.10  Fixed backwards-compatability issue with @LineFeedPos
------------  -------  -------  -------------------------------------------------------------------------------------


=====================================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**********************************************************************************************************************/
--</CommentHeader>

BEGIN
	SET NOCOUNT ON

	--! CONSTANTS (keep it SQL2005 compatible)
	DECLARE @LF					char		(    1 ); SET @LF			= CHAR(10);
	DECLARE @CR					char		(    1 ); SET @CR			= CHAR(13);
	DECLARE @CRLF				char		(    2 ); SET @CRLF			= CHAR(13) + CHAR(10);
	DECLARE @LINE_BREAK			char		(    3 ); SET @LINE_BREAK	= '%' + @LF + '%';

	--! Working Values
	DECLARE @WorkingLength		bigint
	DECLARE @WorkingString		nvarchar		(  max )
	DECLARE @SubString			nvarchar		(  max )
	DECLARE @SubStringLength	bigint

	--! Validate/correct inputs
	SET @MaxPrintLength = COALESCE(NULLIF(@MaxPrintLength, 0), 4000)

	IF @MaxPrintLength > 4000
		BEGIN
			RAISERROR('The @MaxPrintLength value of %i is greater than the maximum length supported by PRINT for nvarchar strings (4000)', 17, 1, @MaxPrintLength);
			RETURN(60000);
		END

	IF @MaxPrintLength < 1
		BEGIN
			RAISERROR('The @MaxPrintLength must be greater than or equal to 1 but is %i', 17, 2, @MaxPrintLength);
			RETURN(60000);
		END

	--! Working variables
	DECLARE @InputLength bigint; SET @InputLength = LEN(@InputString);

	IF @InputLength = 0
		GOTO OnComplete;

	--!
	--! Our input string may contain either carriage returns, line feeds or both
	--! to separate printing lines so we need to standardise on one of these (LF)
	--!
	SET @WorkingString = REPLACE(REPLACE(@InputString, @CRLF, @LF), @CR, @LF);

	--!
	--! If there are line feeds we use those to break down the text
	--! into individual printed lines, otherwise we print it in
	--! bite-size chunks suitable for consumption by PRINT
	--!
	IF PATINDEX(@LINE_BREAK, @InputString) > 0

		BEGIN --[BREAK_BY_LINE_FEED]

			--! Add a line feed on the end so the final iteration works as expected
			SET @WorkingString	= @WorkingString + @LF;
			SET @WorkingLength	= LEN(@WorkingString);

			DECLARE @LineFeedPos bigint; SET @LineFeedPos = 0;

			WHILE @WorkingLength > 0
				BEGIN
					--!
					--! Get the position of the next line feed
					--!
					SET @LineFeedPos = PATINDEX(@LINE_BREAK, @WorkingString);

					IF @LineFeedPos > 0
						BEGIN
							SET @SubString			= SUBSTRING(@WorkingString, 1, @LineFeedPos - 1);
							SET @SubStringLength	= LEN(@SubString);

							--!
							--! If this string is too long for a single PRINT, we pass it back
							--! to PrintString which will process the string in suitably sized chunks
							--!
							IF LEN(@SubString) > @MaxPrintLength
								EXEC [log4].[PrintString] @InputString = @SubString
							ELSE
								PRINT @SubString;

							--! Remove the text we've just processed
							SET @WorkingLength	= @WorkingLength - @LineFeedPos;
							SET @WorkingString	= SUBSTRING(@WorkingString, @LineFeedPos + 1, @WorkingLength);
						END
				END

		END --[BREAK_BY_LINE_FEED]
	ELSE
		BEGIN --[BREAK_BY_LENGTH]
			--!
			--! If there are no line feeds we may have to break it down
			--! into smaller bit size chunks suitable for PRINT
			--!
			IF @InputLength > @MaxPrintLength
				BEGIN
					SET @WorkingString		= @InputString;
					SET @WorkingLength		= LEN(@WorkingString);
					SET @SubStringLength	= @MaxPrintLength;

					WHILE @WorkingLength > 0
						BEGIN
							SET @SubString			= SUBSTRING(@WorkingString, 1, @SubStringLength);
							SET @SubStringLength	= LEN(@SubString)

							--!
							--! If we still have text to process, set working values
							--!
							IF (@WorkingLength - @SubStringLength + 1) > 0
								BEGIN
									PRINT @SubString;
									--! Remove the text we've just processed
									SET @WorkingString	= SUBSTRING(@WorkingString, @SubStringLength + 1, @WorkingLength);
									SET @WorkingLength	= LEN(@WorkingString);
								END
						END
				END
			ELSE
				PRINT @InputString;

		END --[BREAK_BY_LENGTH]

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	SET NOCOUNT OFF

	RETURN

END

GO
GRANT EXECUTE
    ON OBJECT::[log4].[PrintString] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prints the supplied string respecting all line feeds and/or carriage returns except where no line feeds are found, in which case the output is printed in user-specified lengths', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'PrintString';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[PrintString] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[JournalReader]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[JournalReader]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[JournalReader];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[JournalReader]
(
  @StartDate			datetime				= NULL
, @EndDate				datetime				= NULL
, @TimeZoneOffset		smallint				= NULL
, @FunctionName			varchar		(  256 )	= NULL
, @FunctionSearchType	tinyint					= NULL
, @MessageText			varchar		(  512 )	= NULL
, @MessageSearchType	tinyint					= NULL
, @Task					varchar		(  128 )	= NULL
, @SeverityBitMask		smallint				= 8191 -- 8191 All Severities or 7167 to exclude debug
, @ResultSetSize		int						= NULL
)

AS

/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4].[JournalReader]
DESCRIPTION:		Returns all Journal entries matching the specified search criteria
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:			None
DEPENDENCIES:		None

Inputs
======
@DatabaseName
@FunctionName
@MessageText
@StepInFunction
@ExtraInfo
@Severity

Outputs
=======
None

Returns
=======
@@ERROR - always zero on success

Additional Notes
================
Severity Bits (for bitmask):

   1 -- Showstopper/Critical Failure
   2 -- Severe Failure
   4 -- Major Failure
   8 -- Moderate Failure
  16 -- Minor Failure
  32 -- Concurrency Violation
  64 -- Reserved for future Use
 128 -- Reserved for future Use
 256 -- Informational
 512 -- Success
1024 -- Debug
2048 -- Reserved for future Use
4096 -- Reserved for future Use

Function and Message Search Types:

0 = Exclude from Search
1 = Begins With
2 = Ends With
3 = Contains
4 = Exact Match

Revision history
==================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		==============================================================
01-DEC-2006		GML		v0.0.1		Created
------------	------	-------		--------------------------------------------------------------
03-MAY-2011		GML		v0.0.4		Removed ExtraInfo from result set for performance
									Added @TimeZoneOffset for ease of use in other timezones
------------	------	-------		--------------------------------------------------------------
28-AUG-2011		GML		v0.0.6		Added support for ExceptionId and Task columns
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/

BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON

	--! Working variables
	DECLARE	  @Error            int
			, @RowCount         int

	SET @Error 			= 0
	SET @TimeZoneOffset	= COALESCE(@TimeZoneOffset, 0)
	SET @Task			= COALESCE(@Task, '')

	--!
	--! Format the Function search string according to the required search criteria
	--!
	IF LEN(ISNULL(@FunctionName, '')) = 0 OR @FunctionSearchType = 0
		SET @FunctionName = '%'
	ELSE IF LEN(@FunctionName) < 256
		BEGIN
			IF @FunctionSearchType & 1 = 1 AND SUBSTRING(REVERSE(@FunctionName), 1, 1) != '%'
				SET @FunctionName = @FunctionName + '%'

			IF @FunctionSearchType & 2 = 2 AND SUBSTRING(@FunctionName, 1, 1) != '%'
				SET @FunctionName = '%' + @FunctionName

			--! If @FunctionSearchType = 4, do nothing as we want an exact match
		END

	--!
	--! Format the Message search string according to the required search criteria
	--!
	IF LEN(ISNULL(@MessageText, '')) = 0 OR @MessageSearchType = 0
		SET @MessageText = '%'
	ELSE IF LEN(@MessageText) < 512
		BEGIN
			IF @MessageSearchType & 1 = 1 AND SUBSTRING(REVERSE(@MessageText), 1, 1) != '%'
				SET @MessageText = @MessageText + '%'

			IF @MessageSearchType & 2 = 2 AND SUBSTRING(@MessageText, 1, 1) != '%'
				SET @MessageText = '%' + @MessageText

			--! If @MessageSearchType = 4, do nothing as we want an exact match
		END

	--!
	--! If @ResultSetSize is invalid, just return the last 100 rows
	--!
	IF ISNULL(@ResultSetSize, -1) < 1 SET @ResultSetSize = 100
	IF @StartDate IS NULL SET @StartDate = CONVERT(datetime, CONVERT(char(8), DATEADD(day, -7, GETDATE())) + ' 00:00:00', 112)
	IF @EndDate IS NULL SET @EndDate = CONVERT(datetime, CONVERT(char(8), GETDATE(), 112) + ' 23:59:59', 112)

	--! Reverse any time zone offset so we are searching on system time
	SET @StartDate	= DATEADD(hour, @TimeZoneOffset * -1, @StartDate)
	SET @EndDate	= DATEADD(hour, @TimeZoneOffset * -1, @EndDate)

	--!
	--! Return the required results
	--!
	SELECT TOP (@ResultSetSize)
		  j.JournalId
		, DATEADD(hour, @TimeZoneOffset, j.SystemDate)	AS [LocalTime]
		---------------------------------------------------------------------------------------------------
		, j.Task										AS [TaskOrJobName]
		, j.FunctionName								AS [FunctionName]
		, j.StepInFunction								AS [StepInFunction]
		, j.MessageText									AS [MessageText]
		, s.SeverityName								AS [Severity]
		, j.ExceptionId									AS [ExceptionId]
		---------------------------------------------------------------------------------------------------
		, j.SystemDate
	FROM
		[log4].[Journal] AS [j]
	INNER JOIN
		[log4].[Severity] AS [s]
	ON
		s.SeverityId = j.SeverityId
	WHERE
		j.SystemDate BETWEEN @StartDate AND @EndDate
	AND
		j.SeverityId & @SeverityBitMask = j.SeverityId
	AND
		j.Task = COALESCE(NULLIF(@Task, ''), j.Task)
	AND
		j.FunctionName LIKE @FunctionName
	AND
		j.MessageText LIKE @MessageText
	ORDER BY
		j.JournalId DESC

	SELECT @Error = @@ERROR, @RowCount = @@ROWCOUNT

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	SET NOCOUNT OFF

	RETURN(@Error)

END



GO
GRANT EXECUTE
    ON OBJECT::[log4].[JournalReader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns all Journal entries matching the specified search criteria', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'JournalReader';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[JournalReader] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[JournalPrinter]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[JournalPrinter]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[JournalPrinter];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[JournalPrinter]
(
  @JournalId		int
)

AS

/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4].[JournalPrinter]
DESCRIPTION:		Prints the contents of JournalDetail for the specified Journal ID respecting all
					line feeds and/or carriage returns
DATE OF ORIGIN:		03-MAY-2011
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:			None
DEPENDENCIES:		None

Inputs
======
@JournalId - if -1, just processes any provided input string
@InputString - optional, the string to print

Outputs
=======
None

Returns
=======
NULL

Additional Notes
================

Revision history
==================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		==============================================================
03-MAY-2011		GML		v0.0.4		Created
------------	------	-------		--------------------------------------------------------------
05-NOV-2011		GML		v0.0.8		Now calls log4.PrintString (which is SQL2005 compatible)
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/

BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	--! Working Values
	DECLARE @WorkingString		varchar		(  max )

	SELECT @WorkingString = ExtraInfo FROM [log4].[JournalDetail] WHERE JournalId = @JournalId

	IF COALESCE(@WorkingString, '') = ''
		BEGIN
			RAISERROR('No Extra Info for Journal ID: %d!', 0, 1, @JournalId);
		END
	ELSE
		BEGIN
			PRINT '';
			PRINT REPLICATE('=', 120);

			EXEC [log4].[PrintString] @WorkingString

			PRINT '';
			PRINT REPLICATE('=', 120);
			RAISERROR('Completed processing journal detail for Journal ID: %d', 0, 1, @JournalId) WITH NOWAIT;
		END

	SET NOCOUNT OFF;

	RETURN;
END

GO
GRANT EXECUTE
    ON OBJECT::[log4].[JournalPrinter] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prints the contents of JournalDetail for the specified Journal ID respecting all line feeds and/or carriage returns', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'JournalPrinter';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

GRANT EXECUTE ON [log4].[JournalPrinter] TO [public];
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO

--!-------------------------------------------------------------------------------
--! PROCEDURE: [log4].[JournalCleanup]
--!===============================================================================

--<MaintenanceHeader>
/*************************************************************************************************/

IF OBJECTPROPERTY(OBJECT_ID(N'[log4].[JournalCleanup]'), N'IsProcedure') = 1
	DROP PROCEDURE [log4].[JournalCleanup];
GO


SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/*************************************************************************************************/
--</MaintenanceHeader>

CREATE PROCEDURE [log4].[JournalCleanup]
(
  @DaysToKeepJournal            int
, @DaysToKeepException			int
)

AS

/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4].[JournalCleanup]
DESCRIPTION:		Deletes all Journal and Exception entries older than the specified days
DATE OF ORIGIN:		16-FEB-2007
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-MAR-2012
BUILD VERSION:		0.0.10
DEPENDANTS:			None
DEPENDENCIES:		None

Inputs
======
@DatabaseName
@FunctionName
@MessageText
@StepInFunction
@ExtraInfo
@Severity

Outputs
=======
None

Returns
=======
@@ERROR - always zero on success

Additional Notes
================

Revision history
==================================================================================================
ChangeDate		Author	Version		Narrative
============	======	=======		==============================================================
16-FEB-2007		GML		v0.0.2		Created
------------	------	-------		--------------------------------------------------------------
29-AUG-2011		GML		v0.0.7		Added support for ExceptionId (now ensures that Exception
									deleted date is greater than Journa delete date)
------------	------	-------		--------------------------------------------------------------



=================================================================================================
(C) Copyright 2006-12 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

This library is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation (www.fsf.org);
either version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, you can find it at http://www.opensource.org/licenses/lgpl-3.0.html
or http://www.gnu.org/licenses/lgpl.html

**************************************************************************************************/

BEGIN
	SET NOCOUNT ON

	--! Standard/common variables
	DECLARE	  @_Error					int
			, @_RowCount				int
			, @_DatabaseName			nvarchar	(  128 )
			, @_DebugMessage			varchar		( 2000 )
			, @_SprocStartTime			datetime
			, @_StepStartTime			datetime

	--! WriteJournal variables
	DECLARE   @_FunctionName			varchar		(  256 )
			, @_Message					varchar		(  512 )
			, @_ProgressText			nvarchar	(  max )
			, @_Step					varchar		(  128 )
			, @_Severity				smallint

	--! ExceptionHandler variables
	DECLARE   @_CustomErrorText			varchar		(  512 )
			, @_ErrorMessage			varchar		( 4000 )
			, @_ExceptionId				int

	--! Common Debug variables
	DECLARE	  @_LoopStartTime			datetime
			, @_StepEndTime				datetime
			, @_CRLF					char		(    1 )

	--! Populate the common variables
	SET @_SprocStartTime	= GETDATE()
	SET @_FunctionName		= OBJECT_NAME(@@PROCID)
	SET @_DatabaseName		= DB_NAME()
	SET @_Error				= 0
	SET @_Severity			= 256 -- Informational
	SET @_CRLF				= CHAR(10)
	SET @_DebugMessage		= @_FunctionName + ' starting at ' + CONVERT(char(23), @_SprocStartTime, 121) + ' with inputs: '
							+ @_CRLF + '    @DaysToKeepJournal     : ' + COALESCE(CAST(@DaysToKeepJournal AS varchar), 'NULL')
							+ @_CRLF + '    @DaysToKeepException   : ' + COALESCE(CAST(@DaysToKeepException AS varchar), 'NULL')
	SET @_ProgressText		= @_DebugMessage

	--! Define our working values
	DECLARE @_DaysToKeepJournal		int;		SET @_DaysToKeepJournal = COALESCE(@DaysToKeepJournal, 30)
	DECLARE @_DaysToKeepException	int;		SET @_DaysToKeepException = COALESCE(@DaysToKeepException, @_DaysToKeepJournal + 1)
	DECLARE @_JournalArchiveDate	datetime;	SET @_JournalArchiveDate = CONVERT(char(11), DATEADD(day, - @_DaysToKeepJournal, GETDATE()), 113)
	DECLARE @_ExceptionArchiveDate	datetime;	SET @_ExceptionArchiveDate = CONVERT(char(11), DATEADD(day, - @_DaysToKeepException, GETDATE()), 113)

	SET @_ProgressText		= @_ProgressText
							+ @_CRLF + 'and working values...'
							+ @_CRLF + '    @_DaysToKeepJournal     : ' + COALESCE(CAST(@_DaysToKeepJournal AS varchar), 'NULL')
							+ @_CRLF + '    @_DaysToKeepException   : ' + COALESCE(CAST(@_DaysToKeepException AS varchar), 'NULL')
							+ @_CRLF + '    @_JournalArchiveDate   : ' + COALESCE(CONVERT(char(19), @_JournalArchiveDate, 120), 'NULL')
							+ @_CRLF + '    @_ExceptionArchiveDate : ' + COALESCE(CONVERT(char(19), @_ExceptionArchiveDate, 120), 'NULL')

	--!
	--!
	--!
	BEGIN TRY
		SET @_Step = 'Validate inputs';

		--!
		--! There is an FK between Journal and Exception so we can't delete more from Exception
		--! than we do from Journal
		--!
		IF @_JournalArchiveDate >= @_ExceptionArchiveDate
			BEGIN
				SET @_Message	= 'Failed to clean up Journal and Exception tables as Journal delete Date: '
								+ COALESCE(CONVERT(char(19), @_JournalArchiveDate, 120), 'NULL')
								+ ' must be less than Exception delete date: '
								+ COALESCE(CONVERT(char(19), @_ExceptionArchiveDate, 120), 'NULL')
				RAISERROR(@_Message, 16, 1);
			END

		SET @_Step = 'Delete old Journal entries';
		SET @_StepStartTime = GETDATE();

		BEGIN TRAN

		--! Don't need to DELETE JournalDetail as FK cascades
		DELETE
			[log4].[Journal]
		WHERE
			SystemDate < @_JournalArchiveDate

		SET @_RowCount		= @@ROWCOUNT;
		SET @_DebugMessage	= 'Completed step: "' +  COALESCE(@_Step, 'NULL') + '"'
							+ ' in ' + [log4].[FormatElapsedTime](@_StepStartTime, NULL, 3)
							+ ' ' + COALESCE(CAST(@_RowCount AS varchar), 'NULL') + ' row(s) affected'
		SET @_ProgressText	= @_ProgressText + @_CRLF + @_DebugMessage

		IF  @@TRANCOUNT > 0 COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF ABS(XACT_STATE()) = 1 OR @@TRANCOUNT > 0 ROLLBACK TRAN;

		SET @_CustomErrorText	= 'Failed to cleanup Journal and Exception at step: ' + COALESCE(@_Step, 'NULL')

		EXEC [log4].[ExceptionHandler]
				  @DatabaseName    = @_DatabaseName
				, @ErrorContext    = @_CustomErrorText
				, @ErrorProcedure  = @_FunctionName
				, @ErrorNumber     = @_Error OUT
				, @ReturnMessage   = @_Message OUT
				, @ExceptionId     = @_ExceptionId OUT

		GOTO OnComplete;
	END CATCH

	--!
	--!
	--!
	BEGIN TRY
		SET @_Step = 'Delete old Exception entries';
		SET @_StepStartTime = GETDATE();

		BEGIN TRAN

		DELETE
			[log4].[Exception]
		WHERE
			SystemDate < @_ExceptionArchiveDate

		SET @_RowCount		= @@ROWCOUNT;
		SET @_DebugMessage	= 'Completed step: "' +  COALESCE(@_Step, 'NULL') + '"'
							+ ' in ' + [log4].[FormatElapsedTime](@_StepStartTime, NULL, 3)
							+ ' ' + COALESCE(CAST(@_RowCount AS varchar), 'NULL') + ' row(s) affected'
		SET @_ProgressText	= @_ProgressText + @_CRLF + @_DebugMessage

		IF  @@TRANCOUNT > 0 COMMIT TRAN

		SET @_Message		= 'Completed all Journal and Exception cleanup activities;'
							+ ' retaining ' + COALESCE(CAST(@DaysToKeepJournal AS varchar), 'NULL') + ' days'' Journal entries'
							+ ' and ' + COALESCE(CAST(@DaysToKeepException AS varchar), 'NULL') + ' days'' Exception entries'
	END TRY
	BEGIN CATCH
		IF ABS(XACT_STATE()) = 1 OR @@TRANCOUNT > 0 ROLLBACK TRAN;

		SET @_CustomErrorText	= 'Failed to cleanup Journal and Exception at step: ' + COALESCE(@_Step, 'NULL')

		EXEC [log4].[ExceptionHandler]
				  @DatabaseName    = @_DatabaseName
				, @ErrorContext    = @_CustomErrorText
				, @ErrorProcedure  = @_FunctionName
				, @ErrorNumber     = @_Error OUT
				, @ReturnMessage   = @_Message OUT
				, @ExceptionId     = @_ExceptionId OUT

		GOTO OnComplete;
	END CATCH


--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	IF @_Error = 0
		BEGIN
			SET @_Step			= 'OnComplete'
			SET @_Severity		= 512 -- Success
			SET @_Message		= COALESCE(@_Message, @_Step) + ' in a total run time of ' + [log4].[FormatElapsedTime](@_SprocStartTime, NULL, 3)
		END
	ELSE
		BEGIN
			SET @_Step			= COALESCE(@_Step, 'OnError')
			SET @_Severity		= 2 -- Severe Failure
			SET @_Message		= COALESCE(@_Message, @_Step) + ' after a total run time of ' + [log4].[FormatElapsedTime](@_SprocStartTime, NULL, 3)
		END

	--! Always log completion of this call
	EXEC [log4].[JournalWriter]
			  @FunctionName		= @_FunctionName
			, @StepInFunction	= @_Step
			, @MessageText		= @_Message
			, @ExtraInfo		= @_ProgressText
			, @DatabaseName		= @_DatabaseName
			, @Severity			= @_Severity
			, @ExceptionId		= @_ExceptionId

	--! Finaly, throw an exception that will be detected by SQL Agent
	IF @_Error > 0 RAISERROR(@_Message, 16, 1);

	SET NOCOUNT OFF;

	RETURN (@_Error);
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deletes all Journal and Exception entries older than the specified days', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'JournalCleanup';

GO



--<MaintenanceFooter>
/*************************************************************************************************/

--!
--! Do not grant EXECUTE permissions on [log4].[JournalCleanup] to [public]
--!
GO

/*************************************************************************************************/
--</MaintenanceFooter>
GO


SET NOCOUNT OFF;
GO



RAISERROR('', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;
RAISERROR('Completed all component releases', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;
GO

RAISERROR('', 0, 1) WITH NOWAIT;
RAISERROR('---------------------------------------------------------------------------------------------------', 0, 1) WITH NOWAIT;
RAISERROR('COMPLETED ALL RELEASE STEPS', 0, 1) WITH NOWAIT;
PRINT 'Deployment completed at ' + CONVERT(varchar(24), GETDATE(), 121);
GO

SET NOCOUNT OFF;
GO

use master
go

