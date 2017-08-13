create   procedure [CommonModuleTests].[test log4.JournalWriter calls ExceptionHandler on error]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;
	exec tSQLt.SpyProcedure @ProcedureName = N'log4.ExceptionHandler';
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', 'raiserror(''Oops!'', 16, 1);';

	select
		  cast('Failed to write journal entry: "This is a unit test"' as varchar(max)) as [ErrorContext]
		, cast(null as varchar(max)) as [ErrorProcedure]
	into
		#expected

	exec log4.JournalWriter
		  @FunctionName = 'test'
		, @MessageText = 'This is a unit test'

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4.ExceptionHandler_SpyProcedureLog';
end;