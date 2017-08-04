create   procedure [CommonSchemaTests].[test log4Private.Journal.Task defaults to empty string]
as
begin
	--! Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Defaults = 1;

	select 1 as [JournalId], cast('' as varchar(128)) as [Task] into #expected

	--! Act
	insert log4Private.Journal (JournalId) values (1);

	--! Assert
	exec tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = 'log4Private.Journal';
end;