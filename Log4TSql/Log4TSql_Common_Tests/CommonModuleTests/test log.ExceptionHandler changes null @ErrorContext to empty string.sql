create   procedure [CommonModuleTests].[test log.ExceptionHandler changes null @ErrorContext to empty string]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput' ;
	--!
	--! Assemble
	--!
	declare @_Expected nvarchar(500) = '' ;

	--! Act
	begin try
		select 1 / 0 as [ForcedError] into #tmp
	end try
	begin catch
		exec log4.ExceptionHandler @ErrorContext = NULL ;
	end catch

	--! Assert
	declare @_Actual nvarchar(500) = (select ErrorContext from log4Private.SqlException)
	exec tSQLt.AssertEqualsString @_Expected, @_Actual ;
end;