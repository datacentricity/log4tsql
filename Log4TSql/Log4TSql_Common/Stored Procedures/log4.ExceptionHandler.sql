create procedure [log4].[ExceptionHandler]
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
BUILD DATE:			13-AUG-2017
BUILD VERSION:		2.1.0
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
ChangeDate    Author   Version   Narrative
============  ======   =======   ====================================================================================
01-DEC-2006   GML      v0.0.1    Created
------------  ------   -------   ------------------------------------------------------------------------------------
15-APR-2008   GML      v0.0.3    Now utilises SessionInfoOutput sproc for session values
------------  ------   -------   ------------------------------------------------------------------------------------
12-AUG-2017   GML      v2.1.0    Code review, changed license to MIT as part of migration to GitHub
------------  -------  -------   ------------------------------------------------------------------------------------

=====================================================================================================================
(C) Copyright 2006-17 Greg M Lucas. (https://github.com/datacentricity/log4tsql)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

You should have received a copy of the MIT License along with this library; if not, you can find
it at https://opensource.org/licenses/MIT or https://choosealicense.com/licenses/mit/

**********************************************************************************************************************/

begin
	set nocount on;

	declare @_ReturnValue int = 0;
	declare @_ErrorDatabase nvarchar(128) = db_name();
	set @DatabaseName = db_name() -- retained for backwards compatability

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

	begin try
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
		, @_ErrorDatabase
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
	end try
	begin catch
		--!
		--! If we get an internal error,  we still need to try and record that fact
		--!
		declare @_ErrorNumber		int				= error_number() ;
		declare @_ErrorContext		nvarchar(512)	= 'Failed to log exception for: ' + coalesce(nullif(@ErrorProcedure, ''), '"' + @ErrorContext + '"', '') ;
		declare @_ErrorProcedure	nvarchar(128)	= error_procedure() ;
		declare @_ErrorSeverity		int				= error_severity() ;
		declare @_ErrorState		int				= error_state() ;
		declare @_ErrorLine			int				= error_line() ;
		declare @_ErrorMessage		nvarchar(4000)	= error_message() ;

		--! Make sure all the output and return values are populated for the caller:
		set @ErrorContext	= coalesce(@ErrorContext, '');
		set @ErrorProcedure	= coalesce(nullif(@ErrorProcedure, ''),  'Not Found');
		set @ErrorNumber	= coalesce(nullif(@ErrorNumber, 0), 50000);
		set @ErrorSeverity	= coalesce(@ErrorSeverity, 16);
		set @ErrorState		= coalesce(@ErrorState, 1);
		set @ErrorLine		= coalesce(@ErrorLine, 0);
		set @ErrorMessage	= coalesce(nullif(@ErrorMessage, ''), 'Failed to log exception for: ' + coalesce(nullif(@ErrorProcedure, ''), @ErrorContext, ''))
		set @ReturnMessage	= coalesce(@ReturnMessage, @ErrorMessage, '') + ' But failed to log exception due to internal error'
		set @_ReturnValue	= @ErrorNumber;

		--! Finally, try and record the internal exception
		--! We do this directly instead of making another call to log4.ExceptionHandler
		--! to avoid a never ending loop if the problem is actually with this table.
		--! Use an inner TRY...CATCH... to ensure that any caller doesn't fail due to
		--! issues within Log4TSql
		begin try
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
			select
				  @_ErrorContext
				, @_ErrorNumber
				, @_ErrorSeverity
				, @_ErrorState
				, @_ErrorProcedure
				, @_ErrorLine
				, @_ErrorMessage
				, ''
				, 0
				, ''
				, ''
				, ''
				, ''
				, ''
				, ''
				, ''
				, null
		end try
		begin catch
			set @_ReturnValue = error_number();
		end catch
	end catch

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	set nocount off;

	return (@_ReturnValue);
end
go
exec sp_addextendedproperty @name = N'MS_Description', @value = N'Returns error info as output parameters and writes info to Exception table', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'ExceptionHandler';

