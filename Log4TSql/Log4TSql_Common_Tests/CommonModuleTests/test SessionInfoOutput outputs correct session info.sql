CREATE procedure [CommonModuleTests].[test SessionInfoOutput outputs correct session info]
as
begin
	--! Assemble
	select
		  [host_name]				as [HostName]
		, [program_name]			as [ProgramName]
		, [nt_domain]				as [NTDomain]
		, [nt_user_name]			as [NTUsername]
		, [login_name]				as [LoginName]
		, [original_login_name]		as [OriginalLoginName]
		, [login_time]				as [SessionLoginTime]
	into
		[CommonModuleTests].[expected]
	from
		master.sys.dm_exec_sessions with (nolock)
	where
		session_id = @@spid

	--! Variables to capture all outputs
	declare   @actualHostName			nvarchar	( 128 )
			, @actualProgramName		nvarchar	( 128 )
			, @actualNTDomain			nvarchar	( 128 )
			, @actualNTUsername			nvarchar	( 128 )
			, @actualLoginName			nvarchar	( 128 )
			, @actualOriginalLoginName	nvarchar	( 128 )
			, @actualSessionLoginTime	datetime

	-- Act
	exec [log4Private].SessionInfoOutput
			  @SessionId			= @@spid
			, @HostName				= @actualHostName			out
			, @ProgramName			= @actualProgramName		out
			, @NTDomain				= @actualNTDomain			out
			, @NTUsername			= @actualNTUsername			out
			, @LoginName			= @actualLoginName			out
			, @OriginalLoginName	= @actualOriginalLoginName	out
			, @SessionLoginTime		= @actualSessionLoginTime	out

	--! Store the actual values for comparison
	select
		  @actualHostName			as [HostName]
		, @actualProgramName		as [ProgramName]
		, @actualNTDomain			as [NTDomain]
		, @actualNTUsername			as [NTUsername]
		, @actualLoginName			as [LoginName]
		, @actualOriginalLoginName	as [OriginalLoginName]
		, @actualSessionLoginTime	as [SessionLoginTime]
	into [CommonModuleTests].[actual]

	--! Assert
	exec tSQLt.AssertEqualsTable '[CommonModuleTests].[expected]', '[CommonModuleTests].[actual]';
end;