create   procedure [CommonModuleTests].[test log4.JournalWriter inserts log4Private.Journal columns in the correct order]
as
begin
	--!
	--! NOTE: DO NOT fake the Journal table for this INSERT check ao that
	--! if any new NOT NULL columns are added in the future but not
	--! catered for by default constraint or changes in log.JournalWriter
	--! then this test will fail. So start by temporarily dropping any FKs
	--!
	if objectpropertyex(object_id(N'log4Private.FK_Journal_SqlException'), N'IsForeignKey') is not null
		alter table log4Private.Journal drop constraint FK_Journal_SqlException;
	if objectpropertyex(object_id(N'log4Private.FK_JournalDetail_Journal'), N'IsForeignKey') is not null
		alter table log4Private.JournalDetail drop constraint FK_JournalDetail_Journal ;

	exec tSQLt.SpyProcedure @ProcedureName = N'log4.ExceptionHandler', @CommandToExecute = N'declare @_msg nvarchar(1000) = ERROR_MESSAGE(); raiserror(@_msg, 16, 1);'
	
	--! Assemble
	declare @_ExpectedTask varchar(128) = 'A'
		, @_ExpectedFunctionName varchar(256) = 'B'
		, @_ExpectedStepInFunction varchar(128) = 'C'
		, @_ExpectedMessageText varchar(512) = 'D'
		, @_ExpectedSeverityId int = 16
		, @_ExpectedExceptionId int = 789
		, @_ExpectedSessionId int = @@spid
		, @_ExpectedServerName nvarchar(128) = @@servername
		, @_ExpectedDatabaseName nvarchar(128) = 'E'
		, @_ExpectedHostName nvarchar(128) = 'F'
		, @_ExpectedProgramName nvarchar(128) = 'G'
		, @_ExpectedNTDomain nvarchar(128) = 'H'
		, @_ExpectedNTUsername nvarchar(128) = 'I'
		, @_ExpectedLoginName nvarchar(128) = 'J'
		, @_ExpectedOriginalLoginName nvarchar(128) = 'K'
		, @_ExpectedSessionLoginTime datetime = '20020202 02:02:02'

	--!
	--! If we are faking SessionInfoOutput we need to ensure that
	--! the output params are still populated
	--!
	declare @SessionId	int; set @SessionId	= @@spid;
	declare @FakeProcedureCommand varchar(2000);
	set @FakeProcedureCommand = 'SELECT @SessionId = ' + cast(@SessionId as varchar(16))
								+ ', @HostName = ''' + @_ExpectedHostName + ''''
								+ ', @ProgramName = ''' + @_ExpectedProgramName + ''''
								+ ', @NTDomain = ''' + @_ExpectedNTDomain + ''''
								+ ', @NTUsername = ''' + @_ExpectedNTUsername + ''''
								+ ', @LoginName = ''' + @_ExpectedLoginName + ''''
								+ ', @OriginalLoginName = ''' + @_ExpectedOriginalLoginName + ''''
								+ ', @SessionLoginTime = ''' + convert(varchar(24), @_ExpectedSessionLoginTime, 121) + '''';
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput', @FakeProcedureCommand;
	
	select
		  @_ExpectedTask				as [Task]
		, @_ExpectedFunctionName		as [FunctionName]
		, @_ExpectedStepInFunction		as [StepInFunction]
		, @_ExpectedMessageText			as [MessageText]
		, @_ExpectedSeverityId			as [SeverityId]
		, @_ExpectedExceptionId			as [ExceptionId]
		, @_ExpectedSessionId			as [SessionId]
		, @_ExpectedServerName			as [ServerName]
		, @_ExpectedDatabaseName		as [DatabaseName]
		, @_ExpectedHostName			as [HostName]
		, @_ExpectedProgramName			as [ProgramName]
		, @_ExpectedNTDomain			as [NTDomain]
		, @_ExpectedNTUsername			as [NTUsername]
		, @_ExpectedLoginName			as [LoginName]
		, @_ExpectedOriginalLoginName	as [OriginalLoginName]
		, @_ExpectedSessionLoginTime	as [SessionLoginTime]
	into
		#expected
	
	--! act
	exec log4.JournalWriter
		  @FunctionName = @_ExpectedFunctionName
		, @MessageText = @_ExpectedMessageText
		, @DatabaseName = @_ExpectedDatabaseName
		, @Task = @_ExpectedTask
		, @StepInFunction = @_ExpectedStepInFunction
		, @Severity = @_ExpectedSeverityId
		, @ExceptionId = @_ExpectedExceptionId

	exec tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = 'log4Private.Journal' ;
end