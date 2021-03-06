﻿create   procedure [CommonSchemaTests].[test log4Private.Journal.Id primary key is unique]
as
begin
	--Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal' ;
	exec tSQLt.ApplyConstraint 'log4Private.Journal', @ConstraintName = 'PK_Journal'

	--! add the row that we are going to duplicate
	insert log4Private.Journal (JournalId) values (1);

	--! Assert
	exec tSQLt.ExpectException @ExpectedErrorNumber = 2627, @ExpectedMessagePattern = 'Violation of PRIMARY KEY constraint%';
	
	--! add the row again to see if we get the expected error
	insert log4Private.Journal (JournalId) values (1);
end;