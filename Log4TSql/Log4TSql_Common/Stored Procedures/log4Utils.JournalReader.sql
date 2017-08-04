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

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns all Journal entries matching the specified search criteria', @level0type = N'SCHEMA', @level0name = N'log4Utils', @level1type = N'PROCEDURE', @level1name = N'JournalReader';

