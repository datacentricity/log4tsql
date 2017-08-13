create procedure [CommonModuleTests].[test log4.JournalWriter does not record @ExtraInfo when empty]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;

	declare @_JournalId int = 1

	exec log4.JournalWriter
		  @FunctionName = 'test'
		, @MessageText = 'This is a unit test'
		, @ExtraInfo = ''
		, @Severity = 256 -- Informational

	exec tSQLt.AssertEmptyTable @TableName = 'log4Private.JournalDetail' ;
end
go