create   procedure [CommonSchemaTests].[test log4Private.JournalControl column structure]
as
begin
	create table CommonSchemaTests.expected
	(
      ModuleName varchar(255) not null
    , OnOffSwitch varchar(3) not null
	) ;

	exec tSQLt.AssertEqualsTableSchema 'CommonSchemaTests.expected', 'log4Private.JournalControl';
end;