create   procedure [CommonSchemaTests].[test log4Private.Journal.SeverityId must exist in parent table]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Severity' ;
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal' ;
	exec tSQLt.ApplyConstraint @TableName = 'log4Private.Journal', @ConstraintName = 'FK_Journal_Severity'

	exec tSQLt.ExpectException @ExpectedErrorNumber = 547
		, @ExpectedMessagePattern = 'The INSERT statement conflicted with the FOREIGN KEY constraint%';
	
	insert log4Private.Journal (SeverityId) values (-999) ;  
end