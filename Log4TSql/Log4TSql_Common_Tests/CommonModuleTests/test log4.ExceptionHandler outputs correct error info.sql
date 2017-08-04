create   procedure [CommonModuleTests].[test log4.ExceptionHandler outputs correct error info]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput' ;
	--!
	--! Assemble
	--!
	declare @_ErrorContext nvarchar(512) = 'Unit Test Exception Handler' ;
	declare @_ExpectedErrorNumber int = 8134 ;
	declare @_ExpectedErrorSeverity int = 16 ;
	declare @_ExpectedErrorState int = 1 ;
	declare @_ExpectedErrorProcedure nvarchar(128) = object_name(@@procid) ;
	declare @_ExpectedErrorLine int = 39 ; -- may change if the code in this test changes
	declare @_ExpectedErrorMessage nvarchar(max) = 'Divide by zero error encountered.' ;
	declare @_ExpectedReturnMessage nvarchar(max) = @_ErrorContext + ' due to "' + @_ExpectedErrorMessage + '"';

	select
		  @_ExpectedErrorNumber			as [ErrorNumber]
		, @_ExpectedErrorSeverity		as [ErrorSeverity]
		, @_ExpectedErrorState			as [ErrorState]
		, @_ExpectedErrorProcedure		as [ErrorProcedure]
		, @_ExpectedErrorLine			as [ErrorLine]
		, @_ExpectedErrorMessage		as [ErrorMessage]
		, @_ExpectedReturnMessage		as [ReturnMessage]
	into #expected

	--! Act
	declare
		  @_ActualErrorProcedure nvarchar(128)
		, @_ActualErrorNumber    int
		, @_ActualErrorSeverity  int
		, @_ActualErrorState     int
		, @_ActualErrorLine      int
		, @_ActualErrorMessage   nvarchar(4000)
		, @_ActualReturnMessage  nvarchar(1000)

	begin try
		select 1 / 0 as [ForcedError] into #tmp
	end try
	begin catch
		exec log4.ExceptionHandler
			  @ErrorContext = @_ErrorContext
			, @ErrorProcedure = @_ActualErrorProcedure out
			, @ErrorNumber = @_ActualErrorNumber out
			, @ErrorSeverity = @_ActualErrorSeverity out
			, @ErrorState = @_ActualErrorState out
			, @ErrorLine = @_ActualErrorLine out
			, @ErrorMessage = @_ActualErrorMessage out
			, @ReturnMessage = @_ActualReturnMessage out
		
	end catch

	select
		  @_ActualErrorNumber		as [ErrorNumber]
		, @_ActualErrorSeverity		as [ErrorSeverity]
		, @_ActualErrorState		as [ErrorState]
		, @_ActualErrorProcedure	as [ErrorProcedure]
		, @_ActualErrorLine			as [ErrorLine]
		, @_ActualErrorMessage		as [ErrorMessage]
		, @_ActualReturnMessage		as [ReturnMessage]
	into #actual

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', '#actual';
end;