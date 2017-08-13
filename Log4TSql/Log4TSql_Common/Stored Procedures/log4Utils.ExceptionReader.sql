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
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		[log4Utils].[ExceptionReader]
DESCRIPTION:		Returns all Exceptions matching the specified search criteria
DATE OF ORIGIN:		01-DEC-2006
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-AUG-2017
BUILD VERSION:		2.1.1
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
=====================================================================================================================
ChangeDate    Author   Version   Narrative
============  ======   =======   ====================================================================================
01-DEC-2006   GML      v0.0.1    Created
------------  ------   -------   ------------------------------------------------------------------------------------
03-MAY-2011   GML      v0.0.4    Added @TimeZoneOffset for ease of use in other timezones
------------  ------   -------   ------------------------------------------------------------------------------------
12-AUG-2017   GML      v2.1.0    Code review, changed license to MIT as part of migration to GitHub
                                 Also improved error handling in case of internal error
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
exec sp_addextendedproperty @name = N'MS_Description', @value = N'Returns all Exceptions matching the specified search criteria', @level0type = N'SCHEMA', @level0name = N'log4Utils', @level1type = N'PROCEDURE', @level1name = N'ExceptionReader';

