﻿create procedure [ExceptionHandlerAlphaTestHelpers].[RecordsSessionInfo]
(
  @ErrorContext		nvarchar	(  512 )	= null
)
as
begin
	set nocount on;

	declare @exceptionId int;

	begin try
		raiserror('This is a test exception', 16, 99);
	end try
	begin catch
		exec [log4].[ExceptionHandler] @ErrorContext = @ErrorContext, @ExceptionId = @exceptionId out;
	end catch

	select
		  [ErrorDatabase]      as [databaseName]
		, [HostName]           as [hostName]
		, [ProgramName]        as [programName]
		, [NTUsername]         as [nTUsername]
		, [LoginName]          as [loginName]
		, [OriginalLoginName]  as [originalLoginName]
	from
		[log4Private].[SqlException]
	where
		ExceptionId = @exceptionId      

	return;
end