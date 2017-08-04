create   procedure [CommonModuleTests].[test log4.ExceptionHandler calls log4Private.SessionInfoOutput]
as
begin
	--! Assemble
	declare   @ExpectedErrorContext      nvarchar (512) = 'Unit Test Exception Handler'
			, @ExpectedErrorProcedure    nvarchar (128) = 'ExceptionGenerator'
			, @ExpectedErrorDatabase     nvarchar (128) = db_name()
			, @ExpectedSessionId         int            = @@spid
			, @ExpectedServerName        nvarchar(128)  = @@servername
			, @ExpectedHostName          nvarchar (128) = 'F'
			, @ExpectedProgramName       nvarchar (128) = 'G'
			, @ExpectedNTDomain          nvarchar (128) = 'H'
			, @ExpectedNTUsername        nvarchar (128) = 'I'
			, @ExpectedLoginName         nvarchar (128) = 'J'
			, @ExpectedOriginalLoginName nvarchar (128) = 'K'
			, @ExpectedSessionLoginTime  datetime       = '20020202 02:02:02'

	--!
	--! If we are faking SessionInfoOutput we need to ensure that
	--! the output params are still populated
	--!
	declare @SessionId	int; set @SessionId	= @@spid;
	declare @FakeProcedureCommand varchar(2000);
	set @FakeProcedureCommand = 'SELECT @SessionId = ' + cast(@SessionId as varchar(16))
								+ ', @HostName = ''' + @ExpectedHostName + ''''
								+ ', @ProgramName = ''' + @ExpectedProgramName + ''''
								+ ', @NTDomain = ''' + @ExpectedNTDomain + ''''
								+ ', @NTUsername = ''' + @ExpectedNTUsername + ''''
								+ ', @LoginName = ''' + @ExpectedLoginName + ''''
								+ ', @OriginalLoginName = ''' + @ExpectedOriginalLoginName + ''''
								+ ', @SessionLoginTime = ''' + convert(varchar(24), @ExpectedSessionLoginTime, 121) + '''';
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', @FakeProcedureCommand;

	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1 ;

	--! What do we expect to see (i.e. the inputs inserted to the SqlException table)
	select
		  @ExpectedHostName          as [HostName]
		, @ExpectedProgramName       as [ProgramName]
		, @ExpectedNTDomain          as [NTDomain]
		, @ExpectedNTUsername        as [NTUsername]
		, @ExpectedLoginName         as [LoginName]
		, @ExpectedOriginalLoginName as [OriginalLoginName]
		, @ExpectedSessionLoginTime  as [SessionLoginTime]
		, @ExpectedErrorContext		 as [ErrorContext]
		, @ExpectedErrorProcedure    as [ErrorProcedure]
		, @ExpectedErrorDatabase	 as [ErrorDatabase]
	into
		#expected

	exec log4.ExceptionHandler
		  @ErrorContext = @ExpectedErrorContext
		, @ErrorProcedure = @ExpectedErrorProcedure

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.SqlException';
end;