create procedure [ExceptionHandlerAlphaTestHelpers].[ReturnsExpectedOutputParameters]
as
begin
	set nocount on;

	declare @databaseName	nvarchar(128)
	declare @errorProcedure	nvarchar(128)
	declare @errorNumber	int				
	declare @errorSeverity	int					
	declare @errorState		int					
	declare @errorLine		int					
	declare @errorMessage	nvarchar(4000)
	declare @returnMessage	nvarchar(1000)
	declare @exceptionId	int

	begin try
		raiserror('This is a test exception', 16, 99);
	end try
	begin catch
		exec [log4].[ExceptionHandler]
			  @ErrorContext		= null
			, @DatabaseName		= @databaseName out
			, @ErrorProcedure   = @errorProcedure out          
			, @ErrorNumber		= @errorNumber out
			, @ErrorSeverity	= @errorSeverity out
			, @ErrorState		= @errorState out
			, @ErrorLine		= @errorLine out
			, @ErrorMessage		= @errorMessage out
	end catch

	select
		  @databaseName		as [databaseName]
		, @errorProcedure	as [errorProcedure]
		, @errorNumber		as [errorNumber]
		, @errorSeverity	as [errorSeverity]
		, @errorState		as [errorState]
		, @errorLine		as [errorLine]
		, @errorMessage		as [errorMessage]

	return;
end