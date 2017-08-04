create   procedure [StaticDataTests].[test log4Private.JournalControl static data]
as
begin
	--! Assemble
	;with sourceCte (ModuleName, OnOffSwitch)
	as
	(
				  select cast('' as varchar(500)), cast('' as varchar(8))
		union all select 'SYSTEM_DEFAULT'		, 'ON'
		union all select 'SYSTEM_OVERRIDE'		, 'ON'
	)
	select * into #expected from sourceCte where len(ModuleName) > 0

	--! Assert
	exec tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = 'log4Private.JournalControl';
end