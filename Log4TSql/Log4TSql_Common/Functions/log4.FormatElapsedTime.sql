create function [log4].[FormatElapsedTime]
(
  @StartTime                      datetime
, @EndTime                        datetime  = null
, @ShowMillisecsIfUnderNumSecs    tinyint   = null
)
returns varchar(48)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
FUNCTION NAME:      [log4].[FormatElapsedTime]
DESCRIPTION:        Returns a string describing the time elapsed between start and end time
DATE OF ORIGIN:		16-FEB-2007
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-AUG-2017
BUILD VERSION:		2.1.0
DEPENDANTS:         Various
DEPENDENCIES:       None

Additional Notes
================
Builds a string that looks like this: "0 hr(s) 1 min(s) and 22 sec(s)" or "1345 milliseconds"

Revision history
=====================================================================================================================
ChangeDate    Author   Version   Narrative
============  ======   =======   ====================================================================================
16-FEB-2007   GML      v0.0.2    Created
------------  -------  -------   ------------------------------------------------------------------------------------
01-MAR-2015   GML      v0.0.13   Fixed bug when number of hours is greater than 99
------------  -------  -------   ------------------------------------------------------------------------------------
13-AUG-2017   GML      v2.1.0    Code review, changed license to MIT as part of migration to GitHub
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
exec sp_addextendedproperty @name = N'MS_Description', @value = N'Returns a string describing the time elapsed between start and end time', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'FUNCTION', @level1name = N'FormatElapsedTime';

