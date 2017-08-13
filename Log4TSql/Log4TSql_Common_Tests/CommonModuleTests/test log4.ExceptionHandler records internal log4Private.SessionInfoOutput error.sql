CREATE procedure [CommonModuleTests].[test log4.ExceptionHandler records internal log4Private.SessionInfoOutput error]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1 ;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', 'raiserror(''Oops!'', 16, 1);';

	select
		  cast('Failed to log exception for: "This is a unit test"' as varchar(max)) as [ErrorContext]
		, cast('SessionInfoOutput' as varchar(max)) as [ErrorProcedure]
	into
		#expected

	exec log4.ExceptionHandler @ErrorContext = 'This is a unit test'

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.SqlException';
end;