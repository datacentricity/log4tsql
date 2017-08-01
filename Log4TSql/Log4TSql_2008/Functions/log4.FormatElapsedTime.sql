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

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns a user-friendly string describing the time elapsed between start and end time', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'FUNCTION', @level1name = N'FormatElapsedTime';

