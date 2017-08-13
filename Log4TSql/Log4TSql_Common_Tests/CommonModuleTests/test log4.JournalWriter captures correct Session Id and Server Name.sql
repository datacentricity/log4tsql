create   procedure [CommonModuleTests].[test log4.JournalWriter captures correct Session Id and Server Name]
as
begin
	--! Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1 ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;

	declare @_ExpectedSessionId	int= @@spid ;
	declare @_ExpectedServerName nvarchar(128) = @@servername;

	select
		  @_ExpectedSessionId as [SessionId]
		, @_ExpectedServerName as [ServerName]
	into
		#expected

	exec log4.JournalWriter
		  @FunctionName = 'test'
		, @MessageText = 'This is a unit test'

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.Journal';
end
go