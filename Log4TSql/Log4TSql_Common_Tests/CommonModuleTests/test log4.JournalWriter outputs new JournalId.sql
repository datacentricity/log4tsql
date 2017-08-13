create   procedure [CommonModuleTests].[test log4.JournalWriter outputs new JournalId]
as
begin
	--! Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1;

	declare @_actual int;
	exec log4.JournalWriter @FunctionName = 'test', @MessageText = 'This is a unit test', @JournalId = @_actual out;
	
	--! Assert
	exec tSQLt.AssertEquals 1, @_actual ;
end;
go