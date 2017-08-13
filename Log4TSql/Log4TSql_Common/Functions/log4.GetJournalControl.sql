create function [log4].[GetJournalControl]
(
  @ModuleName		varchar(255)
, @GroupName		varchar(255)
)
returns varchar(3)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
FUNCTION NAME:      [log4].[GetJournalControl]
DESCRIPTION:		Returns the ON/OFF value for the specified Journal Name, or Group Name if
					Module not found or the system default if neither is found
DATE OF ORIGIN:		15-APR-2008
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
15-APR-2008   GML      v0.0.3    Created
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

exec sp_addextendedproperty @name = N'MS_Description', @value = N'Returns the ON/OFF value for the specified Journal Name, or Group Name if Module not found or the system default if neither is found', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'FUNCTION', @level1name = N'GetJournalControl';

