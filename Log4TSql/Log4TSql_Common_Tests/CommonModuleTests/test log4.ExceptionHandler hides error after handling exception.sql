CREATE procedure [CommonModuleTests].[test log4.ExceptionHandler hides error after handling exception]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1 ;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', 'select 1 / 0 as [ForcedError] into #tmp;';

	exec tSQLt.ExpectNoException ;
	
	exec log4.JournalWriter
		  @FunctionName = 'test'
		, @MessageText = 'This is a unit test'
end;