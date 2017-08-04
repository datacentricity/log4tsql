create   procedure [CommonSchemaTests].[test log4Private.Severity.Id primary key is unique]
as
begin
	--Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.Severity' ;
	exec tSQLt.ApplyConstraint 'log4Private.Severity', @ConstraintName = 'PK_Severity'

	--! add the row that we are going to duplicate
	insert log4Private.Severity (SeverityId) values (1);

	--! Assert
	exec tSQLt.ExpectException @ExpectedErrorNumber = 2627, @ExpectedMessagePattern = 'Violation of PRIMARY KEY constraint%';
	
	--! add the row again to see if we get the expected error
	insert log4Private.Severity (SeverityId) values (1);
end;