create   procedure [CommonSchemaTests].[test log4Private.JournalControl.OnOffSwitch rejects empty string]
as
begin
	exec tSQLt.FakeTable 'log4Private.JournalControl';
	exec tSQLt.ApplyConstraint @TableName = 'log4Private.JournalControl', @ConstraintName = 'CK_JournalControl_OnOffSwitch';

	declare @ExpectedMessage nvarchar(max) = N'The INSERT statement conflicted with the CHECK constraint "CK_JournalControl_OnOffSwitch". The conflict occurred in database "%", table "log4Private.JournalControl", column ''OnOffSwitch''.'

	exec tSQLt.ExpectException
		  @ExpectedMessagePattern = @ExpectedMessage
		, @ExpectedErrorNumber = 547
	
	insert log4Private.JournalControl (OnOffSwitch) values ('');  
end;