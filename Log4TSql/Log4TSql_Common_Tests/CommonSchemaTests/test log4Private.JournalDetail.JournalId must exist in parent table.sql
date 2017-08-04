create   procedure [CommonSchemaTests].[test log4Private.JournalDetail.JournalId must exist in parent table]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal' ;
	exec tSQLt.FakeTable @TableName = 'log4Private.JournalDetail' ;
	exec tSQLt.ApplyConstraint @TableName = 'log4Private.JournalDetail', @ConstraintName = 'FK_JournalDetail_Journal'

	exec tSQLt.ExpectException @ExpectedErrorNumber = 547
		, @ExpectedMessagePattern = 'The INSERT statement conflicted with the FOREIGN KEY constraint%';
	
	insert log4Private.JournalDetail (JournalId) values (-999) ;  
end