create   procedure [CommonSchemaTests].[test log4Private.JournalDetail.Id primary key is unique]
as
begin
	--Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;
	exec tSQLt.ApplyConstraint 'log4Private.JournalDetail', @ConstraintName = 'PK_JournalDetail'

	--! add the row that we are going to duplicate
	insert log4Private.JournalDetail (JournalId) values (1);

	--! Assert
	exec tSQLt.ExpectException @ExpectedErrorNumber = 2627, @ExpectedMessagePattern = 'Violation of PRIMARY KEY constraint%';
	
	--! add the row again to see if we get the expected error
	insert log4Private.JournalDetail (JournalId) values (1);
end;