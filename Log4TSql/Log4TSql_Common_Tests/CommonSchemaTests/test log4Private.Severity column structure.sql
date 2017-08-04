create   procedure [CommonSchemaTests].[test log4Private.Severity column structure]
as
begin
	create table CommonSchemaTests.expected
	(
	  SeverityId int not null
	, SeverityName varchar(128) not null
	) ;

	exec tSQLt.AssertEqualsTableSchema 'CommonSchemaTests.expected', 'log4Private.Severity';
end;