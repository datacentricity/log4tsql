create function [log4].[GetJournalControl]
(
  @ModuleName		varchar(255)
, @GroupName		varchar(255)
)
returns varchar(3)
as
/**************************************************************************************************

Properties
==========
FUNCTION NAME:      [log4].[GetJournalControl]
DESCRIPTION:		Returns the ON/OFF value for the specified Journal Name, or Group Name if
					Module not found or the system default if neither is found
DATE OF ORIGIN:		15-APR-2008
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
15-APR-2008		GML		v0.0.3		Created
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

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns the ON/OFF value for the specified Journal Name, or Group Name if Module not found or the system default if neither is found', @level0type = N'SCHEMA', @level0name = N'log4', @level1type = N'FUNCTION', @level1name = N'GetJournalControl';

