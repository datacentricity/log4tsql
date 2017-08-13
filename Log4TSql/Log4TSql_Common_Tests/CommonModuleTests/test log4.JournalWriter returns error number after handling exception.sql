create   procedure [CommonModuleTests].[test log4.JournalWriter returns error number after handling exception]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;
	exec tSQLt.SpyProcedure @ProcedureName = N'log4.ExceptionHandler', @CommandToExecute = 'set @ErrorNumber = 999;';
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', 'raiserror(''Oops!'', 16, 1);';

	declare @_actual int;	
	exec @_actual = log4.JournalWriter @FunctionName = 'A', @MessageText = 'B';

	exec tSQLt.AssertEquals @Expected = 999, @Actual = @_actual ;
end;