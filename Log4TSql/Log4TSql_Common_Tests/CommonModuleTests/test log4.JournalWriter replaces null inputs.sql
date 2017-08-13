CREATE procedure [CommonModuleTests].[test log4.JournalWriter replaces null inputs]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;

	declare @_ExpectedDatabaseName nvarchar(128) = db_name()
		, @_ExpectedFunctionName varchar(256) = ''
		, @_ExpectedStepInFunction varchar(128) = ''
		, @_ExpectedMessageText varchar(512) = ''
		, @_ExpectedTask nvarchar(128) = ''

	select
		  @_ExpectedDatabaseName as [DatabaseName]
		, @_ExpectedFunctionName as [FunctionName]
		, @_ExpectedStepInFunction as [StepInFunction]
		, @_ExpectedMessageText as [MessageText]
		, @_ExpectedTask as [Task]
	into
		#expected

	exec log4.JournalWriter
		  @FunctionName = null
		, @MessageText = null
		, @DatabaseName = null
		, @Task = null
		, @StepInFunction = null

	exec tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = 'log4Private.Journal' ;
end
go