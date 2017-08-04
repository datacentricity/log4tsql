create   procedure [CommonModuleTests].[test log4.ExceptionHandler replaces any null error info]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput' ;
	--!
	--! Assemble
	--!
	declare @_ErrorContext nvarchar(512) = 'Not a real error' ;
	declare @_ExpectedErrorNumber int = 0 ;
	declare @_ExpectedErrorSeverity int = 0 ;
	declare @_ExpectedErrorState int = 0 ;
	declare @_ExpectedErrorProcedure nvarchar(128) = '' ;
	declare @_ExpectedErrorLine int = 0 ;
	declare @_ExpectedErrorMessage nvarchar(max) = 'ERROR_MESSAGE() Not Found for @@ERROR: NULL' ;

	select
		  @_ExpectedErrorNumber			as [ErrorNumber]
		, @_ExpectedErrorSeverity		as [ErrorSeverity]
		, @_ExpectedErrorState			as [ErrorState]
		, @_ExpectedErrorProcedure		as [ErrorProcedure]
		, @_ExpectedErrorLine			as [ErrorLine]
		, @_ExpectedErrorMessage		as [ErrorMessage]
	into #expected

	--! Run this without any error context
	exec log4.ExceptionHandler @ErrorContext = @_ErrorContext

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.SqlException';
end;