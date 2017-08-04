create   procedure [CommonSchemaTests].[test log4Private.JournalControl.ModuleName primary key is unique]
as
begin
	--Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalControl' ;
	exec tSQLt.ApplyConstraint 'log4Private.JournalControl', @ConstraintName = 'PK_JournalControl'

	--! add the row that we are going to duplicate
	insert log4Private.JournalControl (ModuleName) values ('X');

	--! Assert
	exec tSQLt.ExpectException @ExpectedErrorNumber = 2627, @ExpectedMessagePattern = 'Violation of PRIMARY KEY constraint%';
	
	--! add the row again to see if we get the expected error
	insert log4Private.JournalControl (ModuleName) values ('X');
end;