create   procedure [CommonModuleTests].[test log.ExceptionHandler inserts columns in correct order]
as
begin
	--!
	--! Assemble
	--!
	declare   @_ExpectedErrorContext      nvarchar (512) = 'Unit Test Exception Handler'
			, @_ExpectedErrorDatabase     nvarchar (128) = db_name()
			, @_ExpectedErrorNumber       int            = 8134
			, @_ExpectedErrorSeverity     int            = 16
			, @_ExpectedErrorState        int            = 1
			, @_ExpectedErrorProcedure    nvarchar (128) = object_name(@@procid)
			, @_ExpectedErrorLine         int            = 76 -- may change if the code in this test changes
			, @_ExpectedErrorMessage      nvarchar (max) = 'Divide by zero error encountered.'
			, @_ExpectedReturnMessage     nvarchar (max) = null
			, @_ExpectedExceptionId       int            = null

	declare   @_ExpectedSessionId         int            = @@spid
			, @_ExpectedServerName        nvarchar (128) = @@servername
			, @_ExpectedHostName          nvarchar (128) = 'F'
			, @_ExpectedProgramName       nvarchar (128) = 'G'
			, @_ExpectedNTDomain          nvarchar (128) = 'H'
			, @_ExpectedNTUsername        nvarchar (128) = 'I'
			, @_ExpectedLoginName         nvarchar (128) = 'J'
			, @_ExpectedOriginalLoginName nvarchar (128) = 'K'
			, @_ExpectedSessionLoginTime  datetime       = getdate()

	--!
	--! NOTE: DO NOT fake the SqlException table for this INSERT check
	--! so that if any new NOT NULL colunns are added in the future but not
	--! catered for by default constraint or changes in log4ExceptionHandler
	--! then this test will fail
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
		  @_ExpectedErrorContext			as [ErrorContext]
		, @_ExpectedErrorNumber			as [ErrorNumber]
		, @_ExpectedErrorSeverity		as [ErrorSeverity]
		, @_ExpectedErrorState			as [ErrorState]
		, @_ExpectedErrorProcedure		as [ErrorProcedure]
		, @_ExpectedErrorLine			as [ErrorLine]
		, @_ExpectedErrorDatabase		as [ErrorDatabase]
		, @_ExpectedErrorMessage			as [ErrorMessage]
		, @_ExpectedSessionId			as [SessionId]
		, @_ExpectedServerName			as [ServerName]
		, @_ExpectedHostName				as [HostName]
		, @_ExpectedProgramName			as [ProgramName]
		, @_ExpectedNTDomain				as [NTDomain]
		, @_ExpectedNTUsername			as [NTUsername]
		, @_ExpectedLoginName			as [LoginName]
		, @_ExpectedOriginalLoginName	as [OriginalLoginName]
		, @_ExpectedSessionLoginTime		as [SessionLoginTime]
	into #expected

	--! Make sure the target table (and its dependants) are empty
	truncate table log4Private.JournalDetail;
	delete log4Private.Journal;
	delete log4Private.SqlException;

	--! Act
	begin try
		select 1 / 0 as [ForcedError] into #tmp
	end try
	begin catch
		exec log4.ExceptionHandler @ErrorContext = @_ExpectedErrorContext ;
	end catch

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.SqlException';
end;