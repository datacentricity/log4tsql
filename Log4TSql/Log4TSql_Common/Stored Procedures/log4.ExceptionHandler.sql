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
	set @ErrorNumber	= coalesce(error_number(), 0);
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

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns error info as output parameters and writes info to Exception table', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'ExceptionHandler';

