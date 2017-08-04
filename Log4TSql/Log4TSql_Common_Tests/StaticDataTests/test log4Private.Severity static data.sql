create   procedure [StaticDataTests].[test log4Private.Severity static data]
as
begin
	--! Assemble
	;with sourceCte (SeverityId, SeverityName)
	as
	(
				  select cast(-1 as int), cast('' as varchar(100))
		union all select 1		, 'Showstopper/Critical Failure'
		union all select 2		, 'Severe Failure'
		union all select 4		, 'Major Failure'
		union all select 8		, 'Moderate Failure'
		union all select 16		, 'Minor Failure'
		union all select 32		, 'Concurrency Violation'
		union all select 256	, 'Informational'
		union all select 512	, 'Success'
		union all select 1024	, 'Debug'
	)
	select * into #expected from sourceCte where SeverityId >= 0

	--! Assert
	exec tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = 'log4Private.Severity';
end