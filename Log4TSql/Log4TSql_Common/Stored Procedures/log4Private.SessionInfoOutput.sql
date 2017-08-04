CREATE procedure [log4Private].[SessionInfoOutput]
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

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Outputs session info from master.sys.dm_exec_sessions for the current @@SPID', @level0type = N'SCHEMA', @level0name = N'log4Private', @level1type = N'PROCEDURE', @level1name = N'SessionInfoOutput';

