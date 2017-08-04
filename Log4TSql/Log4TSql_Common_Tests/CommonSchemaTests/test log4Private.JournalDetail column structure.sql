create   procedure [CommonSchemaTests].[test log4Private.JournalDetail column structure]
as
begin
	create table CommonSchemaTests.expected
	(
	  JournalId int not null
	, ExtraInfo varchar(max) null
	) ;

	exec tSQLt.AssertEqualsTableSchema 'CommonSchemaTests.expected', 'log4Private.JournalDetail';
end;