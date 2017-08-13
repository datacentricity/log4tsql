create procedure [log4Utils].[JournalPrinter]
(
  @JournalId		int
)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		[log4Utils].[JournalPrinter]
DESCRIPTION:		Prints the contents of JournalDetail for the specified Journal ID respecting all
					line feeds and/or carriage returns
DATE OF ORIGIN:		03-MAY-2011
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			13-AUG-2017
BUILD VERSION:		2.1.0
DEPENDANTS:			None
DEPENDENCIES:		None

Inputs
======
@JournalId - if -1, just processes any provided input string
@InputString - optional, the string to print

Outputs
=======
None

Returns
=======
NULL

Additional Notes
================

Revision history
=====================================================================================================================
ChangeDate    Author   Version   Narrative
============  ======   =======   ====================================================================================
03-MAY-2011   GML      v0.0.4    Created
------------  ------   -------   ------------------------------------------------------------------------------------
05-NOV-2011   GML      v0.0.8    Now calls log4.PrintString (which is SQL2005 compatible)
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
	set transaction isolation level read uncommitted;
	set nocount on;

	--! Working Values
	declare @WorkingString		varchar(max)

	select @WorkingString = ExtraInfo from [log4Private].[JournalDetail] where JournalId = @JournalId

	if coalesce(@WorkingString, '') = ''
		begin
			raiserror('No Extra Info for Journal ID: %d!', 0, 1, @JournalId);
		end
	else
		begin
			print '';
			print replicate('=', 120);

			exec [log4Utils].[PrintString] @WorkingString

			print '';
			print replicate('=', 120);
			raiserror('Completed processing journal detail for Journal ID: %d', 0, 1, @JournalId) with nowait;
		end

	set nocount off;

	return;
end
go
exec sp_addextendedproperty @name = N'MS_Description', @value = N'Prints the contents of JournalDetail for the specified Journal ID respecting all line feeds and/or carriage returns', @level0type = N'SCHEMA', @level0name = N'log4Utils', @level1type = N'PROCEDURE', @level1name = N'JournalPrinter';

