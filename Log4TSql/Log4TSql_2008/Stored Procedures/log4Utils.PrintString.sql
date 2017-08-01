create procedure [log4Utils].[PrintString]
(
  @InputString		nvarchar(max)	= null
, @MaxPrintLength	int				= 4000
)
as
/**********************************************************************************************************************

Properties
=====================================================================================================================
PROCEDURE NAME:		[log4Utils].[PrintString]
DESCRIPTION:		Prints the supplied string respecting all line feeds and/or carriage returns except where no
					line feeds are found, in which case the output is printed in user-specified lengths
DATE OF ORIGIN:		05-NOV-2011
ORIGINAL AUTHOR:	Greg M. Lucas (data-centric solutions ltd. http://www.data-centric.co.uk)
BUILD DATE:			01-MAR-2015
BUILD VERSION:		0.0.13
DEPENDANTS:			None
DEPENDENCIES:		None

Inputs
======
@InputString - optional, the string to print
@MaxPrintLength - Max length of string to print before inserting an unnatural break

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
ChangeDate    Author   Version  Narrative
============  =======  =======  =====================================================================================
05-NOV-2011   GML      v0.0.8   Created
------------  -------  -------  -------------------------------------------------------------------------------------
13-MAR-2012   GML      v0.0.10  Fixed backwards-compatability issue with @LineFeedPos
------------  -------  -------  -------------------------------------------------------------------------------------


=====================================================================================================================
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

**********************************************************************************************************************/

begin
	set nocount on

	--! CONSTANTS (keep it SQL2005 compatible)
	declare @LF					char(1); set @LF			= char(10);
	declare @CR					char(1); set @CR			= char(13);
	declare @CRLF				char(2); set @CRLF		= char(13) + char(10);
	declare @LINE_BREAK			char(3); set @LINE_BREAK	= '%' + @LF + '%';

	--! Working Values
	declare @WorkingLength		bigint
	declare @WorkingString		nvarchar(max)
	declare @SubString			nvarchar(max)
	declare @SubStringLength	bigint

	--! Validate/correct inputs
	set @MaxPrintLength = coalesce(nullif(@MaxPrintLength, 0), 4000)

	if @MaxPrintLength > 4000
		begin
			raiserror('The @MaxPrintLength value of %i is greater than the maximum length supported by PRINT for unicode strings (4000)', 17, 1, @MaxPrintLength);
			return(60000);
		end

	if @MaxPrintLength < 1
		begin
			raiserror('The @MaxPrintLength must be greater than or equal to 1 but is %i', 17, 2, @MaxPrintLength);
			return(60000);
		end

	--! Working variables
	declare @InputLength bigint; set @InputLength = len(@InputString);

	if @InputLength = 0
		goto OnComplete;

	--!
	--! Our input string may contain either carriage returns, line feeds or both
	--! to separate printing lines so we need to standardise on one of these (LF)
	--!
	set @WorkingString = replace(replace(@InputString, @CRLF, @LF), @CR, @LF);

	--!
	--! If there are line feeds we use those to break down the text
	--! into individual printed lines, otherwise we print it in
	--! bite-size chunks suitable for consumption by PRINT
	--!
	if patindex(@LINE_BREAK, @InputString) > 0

		begin --[BREAK_BY_LINE_FEED]

			--! Add a line feed on the end so the final iteration works as expected
			set @WorkingString	= @WorkingString + @LF;
			set @WorkingLength	= len(@WorkingString);

			declare @LineFeedPos bigint; set @LineFeedPos = 0;

			while @WorkingLength > 0
				begin
					--!
					--! Get the position of the next line feed
					--!
					set @LineFeedPos = patindex(@LINE_BREAK, @WorkingString);

					if @LineFeedPos > 0
						begin
							set @SubString			= substring(@WorkingString, 1, @LineFeedPos - 1);
							set @SubStringLength	= len(@SubString);

							--!
							--! If this string is too long for a single PRINT, we pass it back
							--! to PrintString which will process the string in suitably sized chunks
							--!
							if len(@SubString) > @MaxPrintLength
								exec [log4Utils].[PrintString] @InputString = @SubString
							else
								print @SubString;

							--! Remove the text we've just processed
							set @WorkingLength	= @WorkingLength - @LineFeedPos;
							set @WorkingString	= substring(@WorkingString, @LineFeedPos + 1, @WorkingLength);
						end
				end

		end --[BREAK_BY_LINE_FEED]
	else
		begin --[BREAK_BY_LENGTH]
			--!
			--! If there are no line feeds we may have to break it down
			--! into smaller bite size chunks suitable for PRINT
			--!
			if @InputLength > @MaxPrintLength
				begin
					set @WorkingString		= @InputString;
					set @WorkingLength		= len(@WorkingString);
					set @SubStringLength	= @MaxPrintLength;

					while @WorkingLength > 0
						begin
							set @SubString			= substring(@WorkingString, 1, @SubStringLength);
							set @SubStringLength	= len(@SubString)

							--!
							--! If we still have text to process, set working values
							--!
							if (@WorkingLength - @SubStringLength + 1) > 0
								begin
									print @SubString;
									--! Remove the text we've just processed
									set @WorkingString	= substring(@WorkingString, @SubStringLength + 1, @WorkingLength);
									set @WorkingLength	= len(@WorkingString);
								end
						end
				end
			else
				print @InputString;

		end --[BREAK_BY_LENGTH]

--/////////////////////////////////////////////////////////////////////////////////////////////////
OnComplete:
--/////////////////////////////////////////////////////////////////////////////////////////////////

	set nocount off

	return
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prints the supplied string respecting all line feeds and/or carriage returns except where no line feeds are found, in which case the output is printed in user-specified lengths', @level0type = N'SCHEMA', @level0name = N'log4Utils', @level1type = N'PROCEDURE', @level1name = N'PrintString';

