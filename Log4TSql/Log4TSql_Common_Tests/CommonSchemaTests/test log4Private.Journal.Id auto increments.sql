create   procedure [CommonSchemaTests].[test log4Private.Journal.Id auto increments]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Identity = 1;

	;with sourceCte (JournalId,  SystemDate)
	as
	(
				  select cast(1 as int) , cast('20010101' as datetime)
		union all select cast(2 as int) , cast('20020202' as datetime)
	)
	select * into #expected from sourceCte ;

	--! Act
	insert log4Private.Journal (SystemDate) values ('20010101'), ('20020202');

	--! Assert
	exec tSQLt.AssertEqualsTable @Expected = N'#expected', @Actual = N'log4Private.Journal';
end;