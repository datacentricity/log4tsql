create   procedure [CommonModuleTests].[test log4.ExceptionHandler outputs valid values on internal error]
as
begin
	--! Faking the SqlException table without adding IDENTITY will force an internal error
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException' ;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput';

	declare @_ActualErrorProcedure nvarchar(128)
		, @_ActualErrorNumber int
		, @_ActualErrorSeverity int
		, @_ActualErrorState int
		, @_ActualErrorLine int
		, @_ActualErrorMessage nvarchar(4000)
		, @_ActualReturnMessage nvarchar(1000)
		, @_ActualExceptionId int

	declare @_ErrorContext nvarchar (512) = 'Unit Test Exception Handler' ;
	declare @ExpectedErrorProcedure nvarchar(128) = 'test log4.ExceptionHandler outputs valid values on internal error' ;
	declare @_ExpectedErrorMessage nvarchar (1000) = 'Divide by zero error encountered.' ;
	declare @_ExpectedReturnMessage nvarchar (1000) = 'Unit Test Exception Handler due to "Divide by zero error encountered." But failed to log exception due to internal error' ;

	select
		  @ExpectedErrorProcedure		as [ErrorProcedure]
		, cast(8134 as int)				as [ErrorNumber]
		, cast(16 as int)				as [ErrorSeverity]
		, cast(1 as int)				as [ErrorState]
		--! ErrorLine value may change if the code in this test changes
		, cast(37 as int)				as [ErrorLine]
		, @_ExpectedErrorMessage		as [ErrorMessage]
		, @_ExpectedReturnMessage		as [ReturnMessage]
		, cast(null as int)				as [ExceptionId]
	into
		#expected

	--! Act
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
			, @ExceptionId = @_ActualExceptionId out
	end catch

	select
		  @_ActualErrorProcedure		as [ErrorProcedure]
		, @_ActualErrorNumber			as [ErrorNumber]
		, @_ActualErrorSeverity			as [ErrorSeverity]
		, @_ActualErrorState			as [ErrorState]
		, @_ActualErrorLine				as [ErrorLine]
		, @_ActualErrorMessage			as [ErrorMessage]
		, @_ActualReturnMessage			as [ReturnMessage]
		, @_ActualExceptionId			as [ExceptionId]
	into
		#actual

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', '#actual' ;
end