create   procedure [CommonModuleTests].[test log4.ExceptionHandler records internal error]
as
begin
	--! Faking the SqlException table without adding IDENTITY will force an internal error
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException' ;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput';

	select
		  cast('Failed to log exception for: my.Testprocedure' as varchar(max)) as [ErrorContext]
		, cast('ExceptionHandler' as varchar(max)) as [ErrorProcedure]
	into
		#expected

	exec log4.ExceptionHandler
		  @ErrorContext = 'This is a unit test'
		, @ErrorProcedure = 'my.Testprocedure'

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.SqlException';
end;