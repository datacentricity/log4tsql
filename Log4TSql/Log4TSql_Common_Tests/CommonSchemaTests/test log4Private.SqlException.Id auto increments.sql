create   procedure [CommonSchemaTests].[test log4Private.SqlException.Id auto increments]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1;

	;with sourceCte (ExceptionId,  SystemDate)
	as
	(
				  select cast(1 as int) , cast('20010101' as datetime)
		union all select cast(2 as int) , cast('20020202' as datetime)
	)
	select * into #expected from sourceCte ;

	--! Act
	insert log4Private.SqlException (SystemDate) values ('20010101'), ('20020202');

	--! Assert
	exec tSQLt.AssertEqualsTable @Expected = N'#expected', @Actual = N'log4Private.SqlException';
end;