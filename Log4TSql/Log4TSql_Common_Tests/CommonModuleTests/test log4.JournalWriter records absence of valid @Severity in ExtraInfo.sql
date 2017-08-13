create procedure [CommonModuleTests].[test log4.JournalWriter records absence of valid @Severity in ExtraInfo]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;

	declare @_JournalId int = 1
	declare @_ExtraInfo varchar(max) = '(Severity value: NULL is invalid so using 256)'

	select
		  @_JournalId as [JournalId]
		, @_ExtraInfo as [ExtraInfo]
	into
		#expected

	exec log4.JournalWriter
		  @FunctionName = 'test'
		, @MessageText = 'This is a unit test'
		, @ExtraInfo = null
		, @Severity = null

	exec tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = 'log4Private.JournalDetail' ;
end
go