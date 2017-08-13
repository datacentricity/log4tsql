create   procedure [CommonModuleTests].[test log4.JournalWriter hides error after handling exception]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;
	exec tSQLt.SpyProcedure @ProcedureName = N'log4.ExceptionHandler', @CommandToExecute = 'set @ErrorNumber = 999;';
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', 'raiserror(''Oops!'', 16, 1);';

	exec tSQLt.ExpectNoException ;
	
	exec log4.JournalWriter
		  @FunctionName = 'test'
		, @MessageText = 'This is a unit test'
end;