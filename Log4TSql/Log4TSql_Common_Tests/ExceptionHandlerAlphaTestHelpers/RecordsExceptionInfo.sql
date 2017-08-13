create procedure [ExceptionHandlerAlphaTestHelpers].[RecordsExceptionInfo]
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
		  [ErrorContext]      as [ErrorContext]
		, [ErrorNumber]       as [ErrorNumber]
		, [ErrorSeverity]     as [ErrorSeverity]
		, [ErrorState]        as [ErrorState]
		, [ErrorProcedure]    as [ErrorProcedure]
		, [ErrorLine]         as [ErrorLine]
		, [ErrorMessage]      as [ErrorMessage]
	from
		[log4Private].[SqlException]
	where
		ExceptionId = @exceptionId      

	return;
end