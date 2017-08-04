create   procedure [CommonSchemaTests].[test log4Private.Severity.Name unique key is unique]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Severity' ;
	exec tSQLt.ApplyConstraint 'log4Private.Severity', @ConstraintName = 'UQ_Severity_SeverityName'

	insert log4Private.Severity (SeverityName) values ('X') ;

	--! Assert
	exec tSQLt.ExpectException
		  @ExpectedErrorNumber = 2627
		, @ExpectedMessagePattern = 'Violation of UNIQUE KEY constraint%';
	
	insert log4Private.Severity (SeverityName) values ('X') ;
end;