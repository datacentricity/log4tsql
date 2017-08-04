create   procedure [CommonModuleTests].[test log.ExceptionHandler identifies current database]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput' ;
	--!
	--! Assemble
	--!
	declare @_ErrorContext nvarchar(512) = 'Unit Test Exception Handler' ;
	declare @_Expected nvarchar(500) = db_name() ;

	--! Act
	begin try
		select 1 / 0 as [ForcedError] into #tmp
	end try
	begin catch
		exec log4.ExceptionHandler @ErrorContext = @_ErrorContext ;
	end catch

	--! Assert
	declare @_Actual nvarchar(500) = (select ErrorDatabase from log4Private.SqlException)
	exec tSQLt.AssertEqualsString @_Expected, @_Actual ;
end;