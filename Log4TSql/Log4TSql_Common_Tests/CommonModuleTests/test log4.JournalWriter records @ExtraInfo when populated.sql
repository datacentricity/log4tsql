create procedure [CommonModuleTests].[test log4.JournalWriter records @ExtraInfo when populated]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;

	declare @_JournalId int = 1
	declare @_ExtraInfo varchar(max) = 'X'

	select
		  @_JournalId as [JournalId]
		, @_ExtraInfo as [ExtraInfo]
	into
		#expected

	exec log4.JournalWriter
		  @FunctionName = 'test'
		, @MessageText = 'This is a unit test'
		, @ExtraInfo = @_ExtraInfo
		, @Severity = 256 -- Informational

	exec tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = 'log4Private.JournalDetail' ;
end
go