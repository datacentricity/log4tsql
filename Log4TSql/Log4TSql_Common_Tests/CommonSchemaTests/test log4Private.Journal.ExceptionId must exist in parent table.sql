create   procedure [CommonSchemaTests].[test log4Private.Journal.ExceptionId must exist in parent table]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException' ;
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal' ;
	exec tSQLt.ApplyConstraint @TableName = 'log4Private.Journal', @ConstraintName = 'FK_Journal_SqlException'

	exec tSQLt.ExpectException @ExpectedErrorNumber = 547
		, @ExpectedMessagePattern = 'The INSERT statement conflicted with the FOREIGN KEY constraint%';
	
	insert log4Private.Journal (ExceptionId) values (-999) ;  
end