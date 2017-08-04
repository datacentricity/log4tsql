create   procedure [CommonSchemaTests].[test log4Private.JournalControl.OnOffSwitch allows "ON" or "OFF"]
as
begin
	exec tSQLt.FakeTable 'log4Private.JournalControl';
	exec tSQLt.ApplyConstraint @TableName = 'log4Private.JournalControl', @ConstraintName = 'CK_JournalControl_OnOffSwitch';

	exec tSQLt.ExpectNoException ;
	
	insert log4Private.JournalControl (OnOffSwitch) values ('ON'), ('OFF');  
end;