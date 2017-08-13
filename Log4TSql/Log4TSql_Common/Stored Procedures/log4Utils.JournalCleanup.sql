create procedure [log4Utils].[JournalCleanup]
(
  @DaysToKeepJournal            int
, @DaysToKeepException			int
)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		[log4Utils].[JournalCleanup]
DESCRIPTION:		Deletes all Journal and Exception entries older than the specified days
DATE OF ORIGIN:		16-FEB-2007
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-AUG-2017
BUILD VERSION:		2.1.0
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
Revision history
=====================================================================================================================
ChangeDate    Author   Version   Narrative
============  ======   =======   ====================================================================================
16-FEB-2007   GML      v0.0.2    Created
------------  ------   -------   ------------------------------------------------------------------------------------
29-AUG-2011   GML      v0.0.7    Added support for ExceptionId (now ensures that Exception deleted date is greater
                                 than Journal delete date)
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
exec sp_addextendedproperty @name = N'MS_Description', @value = N'Deletes all Journal and Exception entries older than the specified days', @level0type = N'SCHEMA', @level0name = N'log4Utils', @level1type = N'PROCEDURE', @level1name = N'JournalCleanup';

