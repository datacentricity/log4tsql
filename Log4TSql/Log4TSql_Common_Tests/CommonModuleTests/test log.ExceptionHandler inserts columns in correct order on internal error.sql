create   procedure [CommonModuleTests].[test log.ExceptionHandler inserts columns in correct order on internal error]
as
begin
	--! Faking the SqlException table without adding IDENTITY will force an internal error
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException' ;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput';

	declare @_ErrorContext nvarchar (512) = 'Unit Test Exception Handler' ;
	declare @_ExpectedErrorContext nvarchar (512) = 'Failed to log exception for: "' + @_ErrorContext + '"' ;
	declare @_ExpectedErrorMessage nvarchar (1000) = 'Cannot insert the value NULL into column ''ExceptionId'', table ''@tblExceptionId''; column does not allow nulls. INSERT fails.' ;

	select
		  @_ExpectedErrorContext						as [ErrorContext]
		, cast(515 as int)								as [ErrorNumber]
		, cast(16 as int)								as [ErrorSeverity]
		, cast(2 as int)								as [ErrorState]
		, cast('ExceptionHandler' as nvarchar(500))		as [ErrorProcedure]
		--! Don't check ErrorLine as this may change if the underlying code changes
		, @_ExpectedErrorMessage						as [ErrorMessage]
		, cast('' as nvarchar(500))						as [ErrorDatabase]
		, cast(0 as int)								as [SessionId]
		, cast('' as nvarchar(500))						as [ServerName]
		, cast('' as nvarchar(500))						as [HostName]
		, cast('' as nvarchar(500))						as [ProgramName]
		, cast('' as nvarchar(500))						as [NTDomain]
		, cast('' as nvarchar(500))						as [NTUsername]
		, cast('' as nvarchar(500))						as [LoginName]
		, cast('' as nvarchar(500))						as [OriginalLoginName]
		, cast(null as datetime)						as [SessionLoginTime]
	into #expected

	--! Act
	exec log4.ExceptionHandler @ErrorContext = @_ErrorContext ;

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.SqlException';
end;