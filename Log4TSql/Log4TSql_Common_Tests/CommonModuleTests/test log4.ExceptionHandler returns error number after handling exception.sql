CREATE procedure [CommonModuleTests].[test log4.ExceptionHandler returns error number after handling exception]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1 ;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', 'select 1 / 0 as [ForcedError] into #tmp;';

	declare @_actual int;	
	exec @_actual = log4.JournalWriter @FunctionName = 'A', @MessageText = 'B';

	exec tSQLt.AssertEquals @Expected = 8134, @Actual = @_actual ;
end;