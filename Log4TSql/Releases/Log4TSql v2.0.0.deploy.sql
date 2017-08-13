use master;

if db_id(N'Log4TSql_v2_0_0') > 0
	drop database [Log4TSql_v2_0_0];
go

create database [Log4TSql_v2_0_0]
go

use [Log4TSql_v2_0_0] ;
go

/**********************************************************************************************************************

(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

if 'log4Private' != 'dbo' and schema_id('log4Private') is null
	exec (N'create schema [log4Private] authorization [dbo];');
go
if 'log4Utils' != 'dbo' and schema_id('log4Utils') is null
	exec (N'create schema [log4Utils] authorization [dbo];');
go
if 'log4' != 'dbo' and schema_id('log4') is null
	exec (N'create schema [log4] authorization [dbo];');
go

if exists (select * from sys.database_principals where type = 'R' and name = 'BatchManagers')
	grant select on schema::[log4Private] to [BatchManagers] ;
go

grant execute on schema::[log4] to [public] ;
go

grant execute on schema::[log4Utils] to [public] ;
go

if objectpropertyex(object_id(N'[log4Private].[JournalControl]'), N'IsUserTable') is null
	create table [log4Private].[JournalControl]
	(
	  ModuleName varchar(255) not null
	, OnOffSwitch varchar(3) not null
	) ;
go

if objectpropertyex(object_id(N'log4Private.PK_JournalControl'), N'IsPrimaryKey') is null
	alter table log4Private.JournalControl add constraint PK_JournalControl primary key clustered (ModuleName) ;
go

if objectpropertyex(object_id(N'log4Private.CK_JournalControl_OnOffSwitch'), N'IsCheckCnst') is null
	alter table log4Private.JournalControl add constraint CK_JournalControl_OnOffSwitch check ((OnOffSwitch = 'OFF' or OnOffSwitch = 'ON')) ;
go

if objectpropertyex(object_id(N'[log4Private].[Severity]'), N'IsUserTable') is null
	create table [log4Private].[Severity]
	(
	  SeverityId int not null
	, SeverityName varchar(128) not null
	) ;
go

if objectpropertyex(object_id(N'log4Private.PK_Severity'), N'IsPrimaryKey') is null
	alter table log4Private.Severity add constraint PK_Severity primary key clustered (SeverityId) ;
go

if objectpropertyex(object_id(N'log4Private.UQ_Severity_SeverityName'), N'IsUniqueCnst') is null
	alter table log4Private.Severity add constraint UQ_Severity_SeverityName unique nonclustered (SeverityName) ;
go

if objectpropertyex(object_id(N'[log4Private].[SqlException]'), N'IsUserTable') is null
	create table [log4Private].[SqlException]
	(
	  ExceptionId int not null identity(1, 1)
	, UtcDate datetime not null constraint DF_SqlException_UtcDate default (getutcdate())
	, SystemDate datetime not null constraint DF_SqlException_SystemDate default (getdate())
	, ErrorContext nvarchar(512) not null
	, ErrorNumber int not null
	, ErrorSeverity int not null
	, ErrorState int not null
	, ErrorProcedure nvarchar(128) not null
	, ErrorLine int not null
	, ErrorMessage nvarchar(max) not null
	, ErrorDatabase nvarchar(128) not null
	, SessionId int not null
	, ServerName nvarchar(128) not null
	, HostName nvarchar(128) not null
	, ProgramName nvarchar(128) not null
	, NTDomain nvarchar(128) not null
	, NTUsername nvarchar(128) not null
	, LoginName nvarchar(128) not null
	, OriginalLoginName nvarchar(128) not null
	, SessionLoginTime datetime null
	) ;
go


if objectpropertyex(object_id(N'log4Private.PK_SqlException'), N'IsPrimaryKey') is null
	alter table log4Private.SqlException add constraint PK_SqlException primary key clustered (ExceptionId) ;
go

--! If the SqlException table still has a SessionIdent column then we need to rename it.
if exists
	(
		select 1 from INFORMATION_SCHEMA.COLUMNS
		where TABLE_SCHEMA = 'log4Private'
		and TABLE_NAME = 'SqlException'
		and COLUMN_NAME = 'SessionIdent'
	)
	begin
		exec sp_rename N'[log4Private].[SqlException].[SessionIdent]', N'SessionId', N'COLUMN'
	end
go


if objectpropertyex(object_id(N'[log4Private].[Journal]'), N'IsUserTable') is null
	create table [log4Private].[Journal]
	(
	  JournalId int not null identity(1, 1)
	, UtcDate datetime not null constraint DF_Journal_UtcDate default (getutcdate())
	, SystemDate datetime not null constraint DF_Journal_SystemDate default (getdate())
	, Task varchar(128) not null constraint DF_Journal_Task default ('')
	, FunctionName varchar(256) not null
	, StepInFunction varchar(128) not null
	, MessageText varchar(512) not null
	, SeverityId int not null
	, ExceptionId int null
	, SessionId int not null
	, ServerName nvarchar(128) not null
	, DatabaseName nvarchar(128) not null
	, HostName nvarchar(128) null
	, ProgramName nvarchar(128) null
	, NTDomain nvarchar(128) null
	, NTUsername nvarchar(128) null
	, LoginName nvarchar(128) null
	, OriginalLoginName nvarchar(128) null
	, SessionLoginTime datetime null
	) ;
go

if objectpropertyex(object_id(N'log4Private.PK_Journal'), N'IsPrimaryKey') is null
	alter table log4Private.Journal add constraint PK_Journal primary key clustered (JournalId) ;
go

if objectpropertyex(object_id(N'log4Private.FK_Journal_Severity'), N'IsForeignKey') is null
	alter table log4Private.Journal add constraint FK_Journal_Severity
    foreign key (SeverityId) references log4Private.Severity (SeverityId) ;
go

if objectpropertyex(object_id(N'log4Private.FK_Journal_SqlException'), N'IsForeignKey') is null
	alter table log4Private.Journal add constraint FK_Journal_SqlException
    foreign key (ExceptionId) references log4Private.SqlException (ExceptionId) ;
go

if objectpropertyex(object_id(N'[log4Private].[JournalDetail]'), N'IsUserTable') is null
	create table [log4Private].[JournalDetail]
	(
	  JournalId int not null
	, ExtraInfo varchar(max) null
	) ;
go

if objectpropertyex(object_id(N'log4Private.PK_JournalDetail'), N'IsPrimaryKey') is null
	alter table log4Private.JournalDetail add constraint PK_JournalDetail primary key clustered (JournalId) ;
go

if objectpropertyex(object_id(N'log4Private.FK_JournalDetail_Journal'), N'IsForeignKey') is null
	alter table log4Private.JournalDetail add constraint FK_JournalDetail_Journal
    foreign key (JournalId) references log4Private.Journal (JournalId) on delete cascade ;
go


set nocount on
go

merge into [log4Private].[Severity] as Target
using (values
  (1,'Showstopper/Critical Failure')
 ,(2,'Severe Failure')
 ,(4,'Major Failure')
 ,(8,'Moderate Failure')
 ,(16,'Minor Failure')
 ,(32,'Concurrency Violation')
 ,(256,'Informational')
 ,(512,'Success')
 ,(1024,'Debug')
) as Source ([SeverityId],[SeverityName])
on (Target.[SeverityId] = Source.[SeverityId])
when matched and (
	nullif(Source.[SeverityName], Target.[SeverityName]) is not null or nullif(Target.[SeverityName], Source.[SeverityName]) is not null) then
 update set
  [SeverityName] = Source.[SeverityName]
when not matched by target then
 insert([SeverityId],[SeverityName])
 values(Source.[SeverityId],Source.[SeverityName])
when not matched by source then 
 delete
;
go
declare @mergeError int
 , @mergeCount int
select @mergeError = @@error, @mergeCount = @@rowcount
if @mergeError != 0
 begin
 print 'ERROR OCCURRED IN MERGE FOR [log4Private].[Severity]. Rows affected: ' + cast(@mergeCount as varchar(100)); -- SQL should always return zero rows affected
 end
else
 begin
 print '[log4Private].[Severity] rows affected by MERGE: ' + cast(@mergeCount as varchar(100));
 end
go

merge into [log4Private].[JournalControl] as Target
using (values
  ('SYSTEM_DEFAULT','ON')
 ,('SYSTEM_OVERRIDE','ON')
) as Source ([ModuleName],[OnOffSwitch])
on (Target.[ModuleName] = Source.[ModuleName])
when matched and (
	nullif(Source.[OnOffSwitch], Target.[OnOffSwitch]) is not null or nullif(Target.[OnOffSwitch], Source.[OnOffSwitch]) is not null) then
 update set
  [OnOffSwitch] = Source.[OnOffSwitch]
when not matched by target then
 insert([ModuleName],[OnOffSwitch])
 values(Source.[ModuleName],Source.[OnOffSwitch])
;
go
declare @mergeError int
 , @mergeCount int
select @mergeError = @@error, @mergeCount = @@rowcount
if @mergeError != 0
 begin
 print 'ERROR OCCURRED IN MERGE FOR [log4Private].[JournalControl]. Rows affected: ' + cast(@mergeCount as varchar(100)); -- SQL should always return zero rows affected
 end
else
 begin
 print '[log4Private].[JournalControl] rows affected by MERGE: ' + cast(@mergeCount as varchar(100));
 end
go

set nocount off
go



if object_id('[log4Private].[SessionInfoOutput]') is not null
	drop procedure [log4Private].[SessionInfoOutput];
go
set quoted_identifier on
go
set ansi_nulls on
go
create procedure [log4Private].[SessionInfoOutput]
(
  @SessionId          int
, @HostName           nvarchar( 128 ) = null  out
, @ProgramName        nvarchar( 128 ) = null  out
, @NTDomain           nvarchar( 128 ) = null  out
, @NTUsername         nvarchar( 128 ) = null  out
, @LoginName          nvarchar( 128 ) = null  out
, @OriginalLoginName  nvarchar( 128 ) = null  out
, @SessionLoginTime   datetime        = null  out
)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:  SessionInfoOutput
DESCRIPTION:     Outputs session info from master.sys.dm_exec_sessions for the current @@SPID
DATE OF ORIGIN:  15-APR-2008
ORIGINAL AUTHOR: Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:      13-MAR-2012
BUILD VERSION:   0.0.11
DEPENDANTS:      log4.ExceptionHandler
                 log4.JournalWriter
DEPENDENCIES:    None (but only works fully on non-azure instances)

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
17-OCT-2015		GML		vX.Y.z		Now works on SQL Azure DB
------------	------	-------		---------------------------------------------------------------------------------

=====================================================================================================================
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set nocount on

	begin try
		--!
		--! sys.dm_exec_sessions tables doesn't exist in Azure so we have to a) set
		--! defaults when running on Azure and b) use dynamic SQL to get the values
		--! from sys.dm_exec_sessions so that this sproc will still compile on Azure
		--!
		if left(@@version, 19) = 'Microsoft SQL Azure'
			begin
				set @HostName			= 'N/S in Azure'
				set @ProgramName		= 'N/S in Azure'
				set @NTDomain			= 'N/S in Azure'
				set @NTUsername			= 'N/S in Azure'
				set @LoginName			= 'N/S in Azure'
				set @OriginalLoginName	= 'N/S in Azure'
				set @SessionLoginTime	= 'N/S in Azure'
			end
		else
			begin
				declare @_cmd nvarchar(max) = 'select'
					+ '  @HostNameOUT = s.[host_name]'
					+ ', @ProgramNameOUT = s.[program_name]'
					+ ', @NTDomainOUT = s.nt_domain'
					+ ', @NTUsernameOUT = s.nt_user_name'
					+ ', @LoginNameOUT = s.login_name'
					+ ', @OriginalLoginNameOUT = s.original_login_name'
					+ ', @SessionLoginTimeOUT = s.login_time'
					+ ' from master.sys.dm_exec_sessions as [s] with (nolock)'
					+ ' where s.session_id = @SessionIdIN' ;
				
				declare @params nvarchar(max) = '@SessionIdIN int'
					+ ', @HostNameOUT nvarchar(128) = null  out'
					+ ', @ProgramNameOUT nvarchar(128) out'
					+ ', @NTDomainOUT nvarchar(128) out'
					+ ', @NTUsernameOUT nvarchar(128) out'
					+ ', @LoginNameOUT nvarchar(128) out'
					+ ', @OriginalLoginNameOUT nvarchar(128) out'
					+ ', @SessionLoginTimeOUT datetime out'

				exec sys.sp_executesql
					  @_cmd
					, @params
					, @SessionIdIN = @SessionId
					, @HostNameOUT = @HostName out
					, @ProgramNameOUT = @ProgramName out
					, @NTDomainOUT = @NTDomain out
					, @NTUsernameOUT = @NTUsername out
					, @LoginNameOUT = @LoginName out
					, @OriginalLoginNameOUT = @OriginalLoginName out
					, @SessionLoginTimeOUT = @SessionLoginTime out
			end
	end try
	begin catch
		--! Make sure we return non-null values
		set @SessionId			= 0
		set @HostName			= ''
		set @ProgramName		= 'log4.SessionInfoOutput Error!'
		set @NTDomain			= ''
		set @NTUsername			= ''
		set @LoginName			= 'log4.SessionInfoOutput Error!'
		set @OriginalLoginName	= ''

		declare @context nvarchar(512); set @context = 'log4.SessionInfoOutput failed to retrieve session info';

		--! Only rollback if we have an uncommitable transaction
		if (xact_state() = -1)
		or (@@trancount > 0 and xact_state() != 1)
			begin
				rollback tran;
				set @context = @context + ' (Forced rolled back of all changes due to uncommitable transaction)';
			end

		--! Log this error directly
		--! Don't call ExceptionHandler in case we get another
		--! SessionInfoOutput error and and up in a never-ending loop)
		insert log4Private.SqlException
		(
		  UtcDate
		, SystemDate
		, ErrorContext
		, ErrorNumber
		, ErrorSeverity
		, ErrorState
		, ErrorProcedure
		, ErrorLine
		, ErrorMessage
		, ErrorDatabase
		, SessionId
		, ServerName
		, HostName
		, ProgramName
		, NTDomain
		, NTUsername
		, LoginName
		, OriginalLoginName
		, SessionLoginTime
		)
		select
			  getutcdate()
			, getdate()
			, @context
			, error_number()
			, error_severity()
			, error_state()
			, coalesce(error_procedure(), 'Dynamic SQL')
			, error_line()
			, error_message()
			, db_name()
			, @@spid
			, @@servername
			, '' -- HostName
			, '' -- ProgramName
			, '' -- NTDomain
			, '' -- NTUsername
			, '' -- LoginName
			, '' -- OriginalLoginName
			, null
	end catch

	set nocount off
end
go
exec sp_addextendedproperty N'MS_Description', N'Outputs session info from master.sys.dm_exec_sessions for the current @@SPID', 'SCHEMA', N'log4Private', 'PROCEDURE', N'SessionInfoOutput', null, null
go


if object_id('[log4].[GetJournalControl]') is not null
	drop function [log4].[GetJournalControl];
go
set quoted_identifier on
go
set ansi_nulls on
go
create function [log4].[GetJournalControl]
(
  @ModuleName		varchar(255)
, @GroupName		varchar(255)
)
returns varchar(3)
as
/**************************************************************************************************

Properties
==========
FUNCTION NAME:      [log4].[GetJournalControl]
DESCRIPTION:		Returns the ON/OFF value for the specified Journal Name, or Group Name if
					Module not found or the system default if neither is found
DATE OF ORIGIN:		15-APR-2008
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
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
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	return
		(
			select
				top 1 OnOffSwitch
			from
				(
						select
							  OnOffSwitch
							, 1 as [Precedence]
						from
							[log4Private].[JournalControl]
						where
							ModuleName = 'SYSTEM_OVERRIDE'
						and
							OnOffSwitch = 'OFF' -- only care about the override when it's OFF
					union
						select
							  OnOffSwitch
							, 10 as [Precedence]
						from
							[log4Private].[JournalControl]
						where
							ModuleName = @ModuleName
					union
						select
							  OnOffSwitch
							, 100 as [Precedence]
						from
							[log4Private].[JournalControl]
						where
							ModuleName = @GroupName
					union
						select
							  OnOffSwitch
							, 200 as [Precedence]
						from
							[log4Private].[JournalControl]
						where
							ModuleName = 'SYSTEM_DEFAULT'
					union
						select
							  'OFF'		as [OnOffSwitch]
							, 300		as [Precedence]
				) as [x]
			order by
				[Precedence] asc
		)
end
go
exec sp_addextendedproperty N'MS_Description', N'Returns the ON/OFF value for the specified Journal Name, or Group Name if Module not found or the system default if neither is found', 'SCHEMA', N'log4', 'FUNCTION', N'GetJournalControl', null, null
go


if object_id('[log4].[FormatElapsedTime]') is not null
	drop function [log4].[FormatElapsedTime];
go
set quoted_identifier on
go
set ansi_nulls on
go
create function [log4].[FormatElapsedTime]
(
  @StartTime                      datetime
, @EndTime                        datetime  = null
, @ShowMillisecsIfUnderNumSecs    tinyint   = null
)
returns varchar(48)
as
/**************************************************************************************************

Properties
==========
FUNCTION NAME:      [log4].[FormatElapsedTime]
DESCRIPTION:        Returns a string describing the time elapsed between start and end time
DATE OF ORIGIN:		16-FEB-2007
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
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
01-MAR-2015		GML		v0.0.13		Fixed bug when number of hours is greater than 99
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	declare	  @time                     int
			, @hrs                      int
			, @mins                     int
			, @secs                     int
			, @msecs                    int
			, @Duration                 varchar(48)

	if @StartTime is null and @EndTime is null
		set @Duration = 'Start and End Times are both NULL'
	else if @StartTime is null
		set @Duration = 'Start Time is NULL'
	else
		begin
			if @EndTime is null set @EndTime = getdate()

			set @time = datediff(ss, @StartTime, @EndTime)

			if @time > isnull(@ShowMillisecsIfUnderNumSecs, 5)
				begin
					set @hrs        = @time / 3600
					set @mins       = (@time % 3600) / 60
					set @secs       = (@time % 3600) % 60
					set @Duration   = case
										when @hrs = 0 then ''
										when @hrs = 1 then cast(@hrs as varchar(4)) + ' hr, '
										else cast(@hrs as varchar(8)) + ' hrs, '
									  end
									+ case
										when @mins = 1 then cast(@mins as varchar(4)) + ' min'
										else cast(@mins as varchar(2)) + ' mins'
									  end
									+ ' and '
									+ case
										when @secs = 1 then cast(@secs as varchar(2)) + ' sec'
										else cast(@secs as varchar(2)) + ' secs'
									  end
				end
			else
				begin
					set @msecs      = datediff(ms, @StartTime, @EndTime)
					set @Duration   = cast(@msecs as varchar(6)) + ' milliseconds'
				end
		end

	return @Duration
end
go
exec sp_addextendedproperty N'MS_Description', N'Returns a string describing the time elapsed between start and end time', 'SCHEMA', N'log4', 'FUNCTION', N'FormatElapsedTime', null, null
go


if object_id('[log4].[ExceptionHandler]') is not null
	drop procedure [log4].[ExceptionHandler];
go
set quoted_identifier on
go
set ansi_nulls on
go
create   procedure [log4].[ExceptionHandler]
(
  @ErrorContext		nvarchar(512)	= null
, @DatabaseName		nvarchar(128)	= null	out -- deprecated
, @ErrorProcedure	nvarchar(128)	= null	out
, @ErrorNumber		int				= null	out
, @ErrorSeverity	int				= null	out
, @ErrorState		int				= null	out
, @ErrorLine		int				= null	out
, @ErrorMessage		nvarchar(4000)	= null	out
, @ReturnMessage	nvarchar(1000)	= null	out
, @ExceptionId		int				= null	out
)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		log4.ExceptionHandler
DESCRIPTION:		Returns error info as output parameters and writes info to Exception table
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
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
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set nocount on;

	set @DatabaseName = db_name() -- retained for backwards compatability
	declare @ErrorDatabase nvarchar(128) = db_name();


	set @ErrorContext	= coalesce(@ErrorContext, '');
	set @ErrorProcedure	= coalesce(nullif(@ErrorProcedure, ''), error_procedure(), '');
	set @ErrorNumber		= coalesce(error_number(), 0);
	set @ErrorSeverity	= coalesce(error_severity(), 0);
	set @ErrorState		= coalesce(error_state(), 0);
	set @ErrorLine		= coalesce(error_line(), 0);
	set @ErrorMessage	= coalesce(error_message()
							, 'ERROR_MESSAGE() Not Found for @@ERROR: '
								+ coalesce(cast(error_number() as varchar(16)), 'NULL'));

	--!
	--! Generate a detailed, nicely formatted error message to return to the caller
	--!
	declare @context nvarchar(512); set @context = coalesce(nullif(@ErrorContext, '') + ' due to ', 'ERROR! ');
	set @ReturnMessage	= @context
						+ case
							when len(error_message()) > (994 - len(@context))
								then '"' + substring(@ErrorMessage, 1, (994 - len(@context))) + '..."'
							else
								'"' + @ErrorMessage + '"'
						  end;

	--!
	--! Session variables (keep it SQL2005 compatible)
	--!
	declare @SessionId		int				; set @SessionId	= @@spid;
	declare @ServerName		nvarchar(128)	; set @ServerName	= @@servername;

	--!
	--! log4.SessionInfoOutput variables
	--!
	declare   @HostName				nvarchar(128)
			, @ProgramName			nvarchar(128)
			, @NTDomain				nvarchar(128)
			, @NTUsername			nvarchar(128)
			, @LoginName			nvarchar(128)
			, @OriginalLoginName	nvarchar(128)
			, @SessionLoginTime		datetime

	--! Working variables
	declare @tblExceptionId         table	(ExceptionId int not null unique);

	--!
	--! Get the details for the current session
	--!
	exec log4Private.SessionInfoOutput
			  @SessionId			= @SessionId
			, @HostName				= @HostName				out
			, @ProgramName			= @ProgramName			out
			, @NTDomain				= @NTDomain				out
			, @NTUsername			= @NTUsername			out
			, @LoginName			= @LoginName			out
			, @OriginalLoginName	= @OriginalLoginName	out
			, @SessionLoginTime		= @SessionLoginTime		out

	--!
	--! Record what we have
	--!
	insert [log4Private].[SqlException]
	(
	  [ErrorContext]
	, [ErrorNumber]
	, [ErrorSeverity]
	, [ErrorState]
	, [ErrorProcedure]
	, [ErrorLine]
	, [ErrorMessage]
	, [ErrorDatabase]
	, [SessionId]
	, [ServerName]
	, [HostName]
	, [ProgramName]
	, [NTDomain]
	, [NTUsername]
	, [LoginName]
	, [OriginalLoginName]
	, [SessionLoginTime]
	)
	output inserted.ExceptionId into @tblExceptionId
	values
	(
	  @ErrorContext
	, @ErrorNumber
	, @ErrorSeverity
	, @ErrorState
	, @ErrorProcedure
	, @ErrorLine
	, @ErrorMessage
	, @ErrorDatabase
	, @SessionId
	, @ServerName
	, @HostName
	, @ProgramName
	, @NTDomain
	, @NTUsername
	, @LoginName
	, @OriginalLoginName
	, @SessionLoginTime
	);

	select @ExceptionId = ExceptionId from @tblExceptionId;

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	set nocount off;

	return;
end
go
exec sp_addextendedproperty N'MS_Description', N'Returns error info as output parameters and writes info to Exception table', 'SCHEMA', N'log4', 'PROCEDURE', N'ExceptionHandler', null, null
go

if object_id('[log4].[JournalWriter]') is not null
	drop procedure [log4].[JournalWriter];
go
set quoted_identifier on
go
set ansi_nulls on
go
create procedure [log4].[JournalWriter]
(
  @FunctionName			varchar(256)
, @MessageText			varchar(512)
, @ExtraInfo			varchar(max)	= null
, @DatabaseName			nvarchar(128)	= null
, @Task					nvarchar(128)	= null
, @StepInFunction		varchar(128)	= null
, @Severity				smallint		= null
, @ExceptionId			int				= null
, @JournalId			int				= null out
)
as
/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4].[JournalWriter]
DESCRIPTION:		Adds a journal entry summarising task progress, completion or failure msgs etc.
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
DEPENDANTS:			Various
DEPENDENCIES:		[log4Private].[SessionInfoOutput]
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
15-APR-2008		GML		v0.0.3		Now utilises [log4Private].[SessionInfoOutput] sproc for session values
------------	------	-------		--------------------------------------------------------------
03-MAY-2011		GML		v0.0.4		Added support for JournalDetail table
------------	------	-------		--------------------------------------------------------------
28-AUG-2011		GML		v0.0.6		Added support for ExceptionId and Task columns
------------	------	-------		--------------------------------------------------------------

=================================================================================================
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set nocount on

	declare @Error int; set @Error = 0;

	--!
	--! Define input defaults
	--!
	set @DatabaseName	= coalesce(@DatabaseName, db_name())
	set @FunctionName	= coalesce(@FunctionName, '')
	set @StepInFunction	= coalesce(@StepInFunction, '')
	set @MessageText	= coalesce(@MessageText, '')
	set @ExtraInfo		= coalesce(@ExtraInfo, '')
	set @Task			= coalesce(@Task, '')

	--! Make sure the supplied severity fits our bitmask model
	if isnull(@Severity, 0) not in (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096)
		begin
			set @ExtraInfo  = coalesce(nullif(@ExtraInfo, '') + char(13), '')
							+ '(Severity value: ' + coalesce(cast(@Severity as varchar(4)), 'NULL') + ' is invalid so using 256)'
			set @Severity   = 256 -- Informational
		end

	--!
	--! Session variables (keep it SQL2005 compatible)
	--!
	declare @SessionId	int				; set @SessionId	= @@spid;
	declare @ServerName	nvarchar(128)	; set @ServerName	= @@servername;

	--!
	--! log4.SessionInfoOutput variables
	--!
	declare   @HostName				nvarchar(128)
			, @ProgramName			nvarchar(128)
			, @NTDomain				nvarchar(128)
			, @NTUsername			nvarchar(128)
			, @LoginName			nvarchar(128)
			, @OriginalLoginName	nvarchar(128)
			, @SessionLoginTime		datetime


	--!
	--! Get the details for the current session
	--!
	exec log4Private.SessionInfoOutput
			  @SessionId			= @SessionId
			, @HostName				= @HostName				out
			, @ProgramName			= @ProgramName			out
			, @NTDomain				= @NTDomain				out
			, @NTUsername			= @NTUsername			out
			, @LoginName			= @LoginName			out
			, @OriginalLoginName	= @OriginalLoginName	out
			, @SessionLoginTime		= @SessionLoginTime		out

	--! Working variables
	declare @tblJournalId table	(JournalId int not null unique);

	begin try
		insert [log4Private].[Journal]
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
	output inserted.JournalId into @tblJournalId
	values
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

		select @JournalId = JournalId from @tblJournalId;

		insert [log4Private].[JournalDetail]
		(
		  JournalId
		, ExtraInfo
		)
		values
		(
		  @JournalId
		, @ExtraInfo
		)

	end try
	begin catch
		--!
		--! If we have an uncommitable transaction (XACT_STATE() = -1), if we hit a deadlock
		--! or if @@TRANCOUNT > 0 AND XACT_STATE() != 1, we HAVE to roll back.
		--! Otherwise, leaving it to the calling process
		--!
		if (@@trancount > 0 and xact_state() != 1) or (xact_state() = -1) or (error_number() = 1205)
			begin
				rollback tran

				set @MessageText    = 'Failed to write journal entry: '
									+ case
										when len(@MessageText) > 440
											then '"' + substring(@MessageText, 1, 440) + '..."'
										else
											coalesce('"' + @MessageText + '"', 'NULL')
										end
									+ ' (Forced roll back of all changes)'
			end
		else
			begin
				set @MessageText    = 'Failed to write journal entry: '
									+ case
										when len(@MessageText) > 475
											then '"' + substring(@MessageText, 1, 475) + '..."'
										else
											coalesce('"' + @MessageText + '"', 'NULL')
										end
			end

		--! Record any failure info
		exec [log4].[ExceptionHandler]
				  @ErrorContext = @MessageText
				, @ErrorNumber  = @Error out
	end catch

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	set nocount off

	return(@Error)

end
go
exec sp_addextendedproperty N'MS_Description', N'Adds a journal entry summarising task progress, completion or failure msgs etc.', 'SCHEMA', N'log4', 'PROCEDURE', N'JournalWriter', null, null
go


if object_id('[log4Utils].[ExceptionReader]') is not null
	drop procedure [log4Utils].[ExceptionReader];
go
set quoted_identifier on
go
set ansi_nulls on
go
create procedure [log4Utils].[ExceptionReader]
(
  @StartDate			datetime		= null
, @EndDate				datetime		= null
, @TimeZoneOffset		smallint		= null
, @ErrorProcedure		varchar(256)	= null
, @ProcedureSearchType	tinyint			= null
, @ErrorMessage			varchar(512)	= null
, @MessageSearchType	tinyint			= null
, @ResultSetSize		int				= null
)
as
/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4Utils].[ExceptionReader]
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
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set transaction isolation level read uncommitted;
	set nocount on;

	--! Working variables
	declare	  @Error            int
			, @RowCount         int

	set @Error 			= 0
	set @TimeZoneOffset	= coalesce(@TimeZoneOffset, 0)

	--!
	--! Format the Function search string according to the required search criteria
	--!
	if len(isnull(@ErrorProcedure, '')) = 0 or @ProcedureSearchType = 0
		set @ErrorProcedure = '%'
	else if len(@ErrorProcedure) < 256
		begin
			if @ProcedureSearchType & 1 = 1 and substring(reverse(@ErrorProcedure), 1, 1) != '%'
				set @ErrorProcedure = @ErrorProcedure + '%'

			if @ProcedureSearchType & 2 = 2 and substring(@ErrorProcedure, 1, 1) != '%'
				set @ErrorProcedure = '%' + @ErrorProcedure

			--! If @ProcedureSearchType = 4, do nothing as we want an exact match
		end

	--!
	--! Format the Message search string according to the required search criteria
	--!
	if len(isnull(@ErrorMessage, '')) = 0 or @MessageSearchType = 0
		set @ErrorMessage = '%'
	else if len(@ErrorMessage) < 512
		begin
			if @MessageSearchType & 1 = 1 and substring(reverse(@ErrorMessage), 1, 1) != '%'
				set @ErrorMessage = @ErrorMessage + '%'

			if @MessageSearchType & 2 = 2 and substring(@ErrorMessage, 1, 1) != '%'
				set @ErrorMessage = '%' + @ErrorMessage

			--! If @MessageSearchType = 4, do nothing as we want an exact match
		end

	--!
	--! If @ResultSetSize is invalid, just return the last 100 rows
	--!
	if isnull(@ResultSetSize, -1) < 1 set @ResultSetSize = 100
	if @StartDate is null set @StartDate = convert(datetime, convert(char(8), dateadd(day, -10, getdate())) + ' 00:00:00', 112)
	if @EndDate is null set @EndDate = convert(datetime, convert(char(8), getdate(), 112) + ' 23:59:59', 112)

	--! Reverse any time zone offset so we are searching on system time
	set @StartDate	= dateadd(hour, @TimeZoneOffset * -1, @StartDate)
	set @EndDate	= dateadd(hour, @TimeZoneOffset * -1, @EndDate)

	--!
	--! Return the required results
	--!
	select top (@ResultSetSize)
		  ExceptionId
		, dateadd(hour, @TimeZoneOffset, SystemDate)						as [LocalTime]
		---------------------------------------------------------------------------------------------------
		, ErrorNumber
		, ErrorContext
		, replace(replace(ErrorMessage, char(13), '  '), char(10), '  ')	as [ErrorMessage]
		, ErrorSeverity
		, ErrorState
		, ErrorProcedure
		, ErrorLine
		, ErrorDatabase
		---------------------------------------------------------------------------------------------------
		, SystemDate
		, SessionId
		, [ProgramName]
		, [NTDomain]
		, [NTUsername]
		, [LoginName]
	from
		[log4Private].[SqlException]
	where
		SystemDate between @StartDate and @EndDate
	and
		ErrorProcedure like @ErrorProcedure
	and
		ErrorMessage like @ErrorMessage
	order by
		ExceptionId desc

	select @Error = @@error, @RowCount = @@rowcount

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	set nocount off

	return(@Error)

end
go
exec sp_addextendedproperty N'MS_Description', N'Returns all Exceptions matching the specified search criteria', 'SCHEMA', N'log4Utils', 'PROCEDURE', N'ExceptionReader', null, null
go


if object_id('[log4Utils].[JournalReader]') is not null
	drop procedure [log4Utils].[JournalReader];
go
set quoted_identifier on
go
set ansi_nulls on
go
create procedure [log4Utils].[JournalReader]
(
  @StartDate			datetime		= null
, @EndDate				datetime		= null
, @TimeZoneOffset		smallint		= null
, @FunctionName			varchar(256)	= null
, @FunctionSearchType	tinyint			= null
, @MessageText			varchar(512)	= null
, @MessageSearchType	tinyint			= null
, @Task					varchar(128)	= null
, @SeverityBitMask		smallint		= 8191 -- 8191 All Severities or 7167 to exclude debug
, @ResultSetSize		int				= null
)
as
/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4Utils].[JournalReader]
DESCRIPTION:		Returns all Journal entries matching the specified search criteria
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
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
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set transaction isolation level read uncommitted;
	set nocount on

	--! Working variables
	declare	  @Error            int
			, @RowCount         int

	set @Error 			= 0
	set @TimeZoneOffset	= coalesce(@TimeZoneOffset, 0)
	set @Task			= coalesce(@Task, '')

	--!
	--! Format the Function search string according to the required search criteria
	--!
	if len(isnull(@FunctionName, '')) = 0 or @FunctionSearchType = 0
		set @FunctionName = '%'
	else if len(@FunctionName) < 256
		begin
			if @FunctionSearchType & 1 = 1 and substring(reverse(@FunctionName), 1, 1) != '%'
				set @FunctionName = @FunctionName + '%'

			if @FunctionSearchType & 2 = 2 and substring(@FunctionName, 1, 1) != '%'
				set @FunctionName = '%' + @FunctionName

			--! If @FunctionSearchType = 4, do nothing as we want an exact match
		end

	--!
	--! Format the Message search string according to the required search criteria
	--!
	if len(isnull(@MessageText, '')) = 0 or @MessageSearchType = 0
		set @MessageText = '%'
	else if len(@MessageText) < 512
		begin
			if @MessageSearchType & 1 = 1 and substring(reverse(@MessageText), 1, 1) != '%'
				set @MessageText = @MessageText + '%'

			if @MessageSearchType & 2 = 2 and substring(@MessageText, 1, 1) != '%'
				set @MessageText = '%' + @MessageText

			--! If @MessageSearchType = 4, do nothing as we want an exact match
		end

	--!
	--! If @ResultSetSize is invalid, just return the last 100 rows
	--!
	if isnull(@ResultSetSize, -1) < 1 set @ResultSetSize = 100
	if @StartDate is null set @StartDate = convert(datetime, convert(char(8), dateadd(day, -7, getdate())) + ' 00:00:00', 112)
	if @EndDate is null set @EndDate = convert(datetime, convert(char(8), getdate(), 112) + ' 23:59:59', 112)

	--! Reverse any time zone offset so we are searching on system time
	set @StartDate	= dateadd(hour, @TimeZoneOffset * -1, @StartDate)
	set @EndDate	= dateadd(hour, @TimeZoneOffset * -1, @EndDate)

	--!
	--! Return the required results
	--!
	select top (@ResultSetSize)
		  j.JournalId
		, dateadd(hour, @TimeZoneOffset, j.SystemDate)	as [LocalTime]
		---------------------------------------------------------------------------------------------------
		, j.Task										as [TaskOrJobName]
		, j.FunctionName								as [FunctionName]
		, j.StepInFunction								as [StepInFunction]
		, j.MessageText									as [MessageText]
		, s.SeverityName								as [Severity]
		, j.ExceptionId									as [ExceptionId]
		---------------------------------------------------------------------------------------------------
		, j.SystemDate
	from
		[log4Private].[Journal] as [j]
	inner join
		[log4Private].[Severity] as [s]
	on
		s.SeverityId = j.SeverityId
	where
		j.SystemDate between @StartDate and @EndDate
	and
		j.SeverityId & @SeverityBitMask = j.SeverityId
	and
		j.Task = coalesce(nullif(@Task, ''), j.Task)
	and
		j.FunctionName like @FunctionName
	and
		j.MessageText like @MessageText
	order by
		j.JournalId desc

	select @Error = @@error, @RowCount = @@rowcount

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	set nocount off

	return(@Error)

end
go
exec sp_addextendedproperty N'MS_Description', N'Returns all Journal entries matching the specified search criteria', 'SCHEMA', N'log4Utils', 'PROCEDURE', N'JournalReader', null, null
go


if object_id('[log4Utils].[PrintString]') is not null
	drop procedure [log4Utils].[PrintString];
go
set quoted_identifier on
go
set ansi_nulls on
go
create procedure [log4Utils].[PrintString]
(
  @InputString		nvarchar(max)	= null
, @MaxPrintLength	int				= 4000
)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		[log4Utils].[PrintString]
DESCRIPTION:		Prints the supplied string respecting all line feeds and/or carriage returns except where no
					line feeds are found, in which case the output is printed in user-specified lengths
DATE OF ORIGIN:		05-NOV-2011
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
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
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set nocount on

	--! CONSTANTS (keep it SQL2005 compatible)
	declare @LF					char(1); set @LF			= char(10);
	declare @CR					char(1); set @CR			= char(13);
	declare @CRLF				char(2); set @CRLF		= char(13) + char(10);
	declare @LINE_BREAK			char(3); set @LINE_BREAK	= '%' + @LF + '%';

	--! Working Values
	declare @WorkingLength		bigint
	declare @WorkingString		nvarchar(max)
	declare @SubString			nvarchar(max)
	declare @SubStringLength	bigint

	--! Validate/correct inputs
	set @MaxPrintLength = coalesce(nullif(@MaxPrintLength, 0), 4000)

	if @MaxPrintLength > 4000
		begin
			raiserror('The @MaxPrintLength value of %i is greater than the maximum length supported by PRINT for unicode strings (4000)', 17, 1, @MaxPrintLength);
			return(60000);
		end

	if @MaxPrintLength < 1
		begin
			raiserror('The @MaxPrintLength must be greater than or equal to 1 but is %i', 17, 2, @MaxPrintLength);
			return(60000);
		end

	--! Working variables
	declare @InputLength bigint; set @InputLength = len(@InputString);

	if @InputLength = 0
		goto OnComplete;

	--!
	--! Our input string may contain either carriage returns, line feeds or both
	--! to separate printing lines so we need to standardise on one of these (LF)
	--!
	set @WorkingString = replace(replace(@InputString, @CRLF, @LF), @CR, @LF);

	--!
	--! If there are line feeds we use those to break down the text
	--! into individual printed lines, otherwise we print it in
	--! bite-size chunks suitable for consumption by PRINT
	--!
	if patindex(@LINE_BREAK, @InputString) > 0

		begin --[BREAK_BY_LINE_FEED]

			--! Add a line feed on the end so the final iteration works as expected
			set @WorkingString	= @WorkingString + @LF;
			set @WorkingLength	= len(@WorkingString);

			declare @LineFeedPos bigint; set @LineFeedPos = 0;

			while @WorkingLength > 0
				begin
					--!
					--! Get the position of the next line feed
					--!
					set @LineFeedPos = patindex(@LINE_BREAK, @WorkingString);

					if @LineFeedPos > 0
						begin
							set @SubString			= substring(@WorkingString, 1, @LineFeedPos - 1);
							set @SubStringLength	= len(@SubString);

							--!
							--! If this string is too long for a single PRINT, we pass it back
							--! to PrintString which will process the string in suitably sized chunks
							--!
							if len(@SubString) > @MaxPrintLength
								exec [log4Utils].[PrintString] @InputString = @SubString
							else
								print @SubString;

							--! Remove the text we've just processed
							set @WorkingLength	= @WorkingLength - @LineFeedPos;
							set @WorkingString	= substring(@WorkingString, @LineFeedPos + 1, @WorkingLength);
						end
				end

		end --[BREAK_BY_LINE_FEED]
	else
		begin --[BREAK_BY_LENGTH]
			--!
			--! If there are no line feeds we may have to break it down
			--! into smaller bite size chunks suitable for PRINT
			--!
			if @InputLength > @MaxPrintLength
				begin
					set @WorkingString		= @InputString;
					set @WorkingLength		= len(@WorkingString);
					set @SubStringLength	= @MaxPrintLength;

					while @WorkingLength > 0
						begin
							set @SubString			= substring(@WorkingString, 1, @SubStringLength);
							set @SubStringLength	= len(@SubString)

							--!
							--! If we still have text to process, set working values
							--!
							if (@WorkingLength - @SubStringLength + 1) > 0
								begin
									print @SubString;
									--! Remove the text we've just processed
									set @WorkingString	= substring(@WorkingString, @SubStringLength + 1, @WorkingLength);
									set @WorkingLength	= len(@WorkingString);
								end
						end
				end
			else
				print @InputString;

		end --[BREAK_BY_LENGTH]

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	set nocount off

	return
end
go
exec sp_addextendedproperty N'MS_Description', N'Prints the supplied string respecting all line feeds and/or carriage returns except where no line feeds are found, in which case the output is printed in user-specified lengths', 'SCHEMA', N'log4Utils', 'PROCEDURE', N'PrintString', null, null
go

if object_id('[log4Utils].[JournalPrinter]') is not null
	drop procedure [log4Utils].[JournalPrinter];
go
set quoted_identifier on
go
set ansi_nulls on
go
create procedure [log4Utils].[JournalPrinter]
(
  @JournalId		int
)
as
/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4Utils].[JournalPrinter]
DESCRIPTION:		Prints the contents of JournalDetail for the specified Journal ID respecting all
					line feeds and/or carriage returns
DATE OF ORIGIN:		03-MAY-2011
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
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
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set transaction isolation level read uncommitted;
	set nocount on;

	--! Working Values
	declare @WorkingString		varchar(max)

	select @WorkingString = ExtraInfo from [log4Private].[JournalDetail] where JournalId = @JournalId

	if coalesce(@WorkingString, '') = ''
		begin
			raiserror('No Extra Info for Journal ID: %d!', 0, 1, @JournalId);
		end
	else
		begin
			print '';
			print replicate('=', 120);

			exec [log4Utils].[PrintString] @WorkingString

			print '';
			print replicate('=', 120);
			raiserror('Completed processing journal detail for Journal ID: %d', 0, 1, @JournalId) with nowait;
		end

	set nocount off;

	return;
end
go
exec sp_addextendedproperty N'MS_Description', N'Prints the contents of JournalDetail for the specified Journal ID respecting all line feeds and/or carriage returns', 'SCHEMA', N'log4Utils', 'PROCEDURE', N'JournalPrinter', null, null
go



if object_id('[log4Utils].[JournalCleanup]') is not null
	drop procedure [log4Utils].[JournalCleanup];
go
set quoted_identifier on
go
set ansi_nulls on
go
create procedure [log4Utils].[JournalCleanup]
(
  @DaysToKeepJournal            int
, @DaysToKeepException			int
)
as
/**************************************************************************************************

Properties
==========
PROCEDURE NAME:		[log4Utils].[JournalCleanup]
DESCRIPTION:		Deletes all Journal and Exception entries older than the specified days
DATE OF ORIGIN:		16-FEB-2007
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
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
(C) Copyright 2006-14 data-centric solutions ltd. (http://log4tsql.sourceforge.net/)

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

begin
	set nocount on

	--! Standard/common variables
	declare	  @_Error					int
			, @_RowCount				int
			, @_DatabaseName			nvarchar(128)
			, @_DebugMessage			varchar(2000)
			, @_SprocStartTime			datetime
			, @_StepStartTime			datetime

	--! WriteJournal variables
	declare   @_FunctionName			varchar(256)
			, @_Message					varchar(512)
			, @_ProgressText			nvarchar(max)
			, @_Step					varchar(128)
			, @_Severity				smallint

	--! ExceptionHandler variables
	declare   @_CustomErrorText			varchar(512)
			, @_ErrorMessage			varchar(4000)
			, @_ExceptionId				int

	--! Common Debug variables
	declare	  @_LoopStartTime			datetime
			, @_StepEndTime				datetime
			, @_CRLF					char(1)

	--! Populate the common variables
	set @_SprocStartTime	= getdate()
	set @_FunctionName		= object_name(@@procid)
	set @_DatabaseName		= db_name()
	set @_Error				= 0
	set @_Severity			= 256 -- Informational
	set @_CRLF				= char(10)
	set @_DebugMessage		= @_FunctionName + ' starting at ' + convert(char(23), @_SprocStartTime, 121) + ' with inputs: '
							+ @_CRLF + '    @DaysToKeepJournal     : ' + coalesce(cast(@DaysToKeepJournal as varchar(8)), 'NULL')
							+ @_CRLF + '    @DaysToKeepException   : ' + coalesce(cast(@DaysToKeepException as varchar(8)), 'NULL')
	set @_ProgressText		= @_DebugMessage

	--! Define our working values
	declare @_DaysToKeepJournal		int;		set @_DaysToKeepJournal = coalesce(@DaysToKeepJournal, 30)
	declare @_DaysToKeepException	int;		set @_DaysToKeepException = coalesce(@DaysToKeepException, @_DaysToKeepJournal + 1)
	declare @_JournalArchiveDate	datetime;	set @_JournalArchiveDate = convert(char(11), dateadd(day, - @_DaysToKeepJournal, getdate()), 113)
	declare @_ExceptionArchiveDate	datetime;	set @_ExceptionArchiveDate = convert(char(11), dateadd(day, - @_DaysToKeepException, getdate()), 113)

	set @_ProgressText		= @_ProgressText
							+ @_CRLF + 'and working values...'
							+ @_CRLF + '    @_DaysToKeepJournal     : ' + coalesce(cast(@_DaysToKeepJournal as varchar(8)), 'NULL')
							+ @_CRLF + '    @_DaysToKeepException   : ' + coalesce(cast(@_DaysToKeepException as varchar(8)), 'NULL')
							+ @_CRLF + '    @_JournalArchiveDate   : ' + coalesce(convert(char(19), @_JournalArchiveDate, 120), 'NULL')
							+ @_CRLF + '    @_ExceptionArchiveDate : ' + coalesce(convert(char(19), @_ExceptionArchiveDate, 120), 'NULL')

	--!
	--!
	--!
	begin try
		set @_Step = 'Validate inputs';

		--!
		--! There is an FK between Journal and Exception so we can't delete more from Exception
		--! than we do from Journal
		--!
		if @_JournalArchiveDate >= @_ExceptionArchiveDate
			begin
				set @_Message	= 'Failed to clean up Journal and Exception tables as Journal delete Date: '
								+ coalesce(convert(char(19), @_JournalArchiveDate, 120), 'NULL')
								+ ' must be less than Exception delete date: '
								+ coalesce(convert(char(19), @_ExceptionArchiveDate, 120), 'NULL')
				raiserror(@_Message, 16, 1);
			end

		set @_Step = 'Delete old Journal entries';
		set @_StepStartTime = getdate();

		begin tran

		--! Don't need to DELETE JournalDetail as FK cascades
		delete
			[log4Private].[Journal]
		where
			SystemDate < @_JournalArchiveDate

		set @_RowCount		= @@rowcount;
		set @_DebugMessage	= 'Completed step: "' +  coalesce(@_Step, 'NULL') + '"'
							+ ' in ' + [log4].[FormatElapsedTime](@_StepStartTime, null, 3)
							+ ' ' + coalesce(cast(@_RowCount as varchar(8)), 'NULL') + ' row(s) affected'
		set @_ProgressText	= @_ProgressText + @_CRLF + @_DebugMessage

		if  @@trancount > 0 commit tran
	end try
	begin catch
		if abs(xact_state()) = 1 or @@trancount > 0 rollback tran;

		set @_CustomErrorText	= 'Failed to cleanup Journal and Exception at step: ' + coalesce(@_Step, 'NULL')

		exec [log4].[ExceptionHandler]
				  @ErrorContext    = @_CustomErrorText
				, @ErrorProcedure  = @_FunctionName
				, @ErrorNumber     = @_Error out
				, @ReturnMessage   = @_Message out
				, @ExceptionId     = @_ExceptionId out

		goto OnComplete;
	end catch

	--!
	--!
	--!
	begin try
		set @_Step = 'Delete old Exception entries';
		set @_StepStartTime = getdate();

		begin tran

		delete
			[log4Private].[SqlException]
		where
			SystemDate < @_ExceptionArchiveDate

		set @_RowCount		= @@rowcount;
		set @_DebugMessage	= 'Completed step: "' +  coalesce(@_Step, 'NULL') + '"'
							+ ' in ' + [log4].[FormatElapsedTime](@_StepStartTime, null, 3)
							+ ' ' + coalesce(cast(@_RowCount as varchar(8)), 'NULL') + ' row(s) affected'
		set @_ProgressText	= @_ProgressText + @_CRLF + @_DebugMessage

		if  @@trancount > 0 commit tran

		set @_Message		= 'Completed all Journal and Exception cleanup activities;'
							+ ' retaining ' + coalesce(cast(@DaysToKeepJournal as varchar(8)), 'NULL') + ' days'' Journal entries'
							+ ' and ' + coalesce(cast(@DaysToKeepException as varchar(8)), 'NULL') + ' days'' Exception entries'
	end try
	begin catch
		if abs(xact_state()) = 1 or @@trancount > 0 rollback tran;

		set @_CustomErrorText	= 'Failed to cleanup Journal and Exception at step: ' + coalesce(@_Step, 'NULL')

		exec [log4].[ExceptionHandler]
				  @ErrorContext    = @_CustomErrorText
				, @ErrorProcedure  = @_FunctionName
				, @ErrorNumber     = @_Error out
				, @ReturnMessage   = @_Message out
				, @ExceptionId     = @_ExceptionId out

		goto OnComplete;
	end catch


--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	if @_Error = 0
		begin
			set @_Step			= 'OnComplete'
			set @_Severity		= 512 -- Success
			set @_Message		= coalesce(@_Message, @_Step) + ' in a total run time of ' + [log4].[FormatElapsedTime](@_SprocStartTime, null, 3)
		end
	else
		begin
			set @_Step			= coalesce(@_Step, 'OnError')
			set @_Severity		= 2 -- Severe Failure
			set @_Message		= coalesce(@_Message, @_Step) + ' after a total run time of ' + [log4].[FormatElapsedTime](@_SprocStartTime, null, 3)
		end

	--! Always log completion of this call
	exec [log4].[JournalWriter]
			  @FunctionName		= @_FunctionName
			, @StepInFunction	= @_Step
			, @MessageText		= @_Message
			, @ExtraInfo		= @_ProgressText
			, @DatabaseName		= @_DatabaseName
			, @Severity			= @_Severity
			, @ExceptionId		= @_ExceptionId

	--! Finaly, throw an exception that will be detected by SQL Agent
	if @_Error > 0 raiserror(@_Message, 16, 1);

	set nocount off;

	return (@_Error);
end
go
exec sp_addextendedproperty N'MS_Description', N'Deletes all Journal and Exception entries older than the specified days', 'SCHEMA', N'log4Utils', 'PROCEDURE', N'JournalCleanup', null, null
go

use master
go




















