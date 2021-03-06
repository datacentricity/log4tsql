﻿create procedure [log4].[JournalWriter]
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
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		[log4].[JournalWriter]
DESCRIPTION:		Adds a journal entry summarising task progress, completion or failure msgs etc.
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-AUG-2017
BUILD VERSION:		2.1.1
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
=====================================================================================================================
ChangeDate    Author   Version   Narrative
============  ======   =======   ====================================================================================
01-DEC-2006   GML      v0.0.1    Created
------------  ------   -------   ------------------------------------------------------------------------------------
15-APR-2008   GML      v0.0.3    Now utilises [log4Private].[SessionInfoOutput] sproc for session values
------------  ------   -------   ------------------------------------------------------------------------------------
03-MAY-2011   GML      v0.0.4    Added support for JournalDetail table
------------  ------   -------   ------------------------------------------------------------------------------------
28-AUG-2011   GML      v0.0.6    Added support for ExceptionId and Task columns
------------  ------   -------   ------------------------------------------------------------------------------------
12-AUG-2017   GML      v2.1.0    Code review, changed license to MIT as part of migration to GitHub
------------  ------   -------   ------------------------------------------------------------------------------------

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

	--! Working variables
	declare @tblJournalId table	(JournalId int not null unique);

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
		) ;

		select @JournalId = JournalId from @tblJournalId;

		if len(@ExtraInfo) > 0
			insert [log4Private].[JournalDetail]
			(
			  JournalId
			, ExtraInfo
			)
			values
			(
			  @JournalId
			, @ExtraInfo
			) ;

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
exec sp_addextendedproperty @name = N'MS_Description', @value = N'Adds a journal entry summarising task progress, completion or failure msgs etc.', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'PROCEDURE', @level1name = N'JournalWriter';

