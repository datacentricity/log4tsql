create   procedure [CommonModuleTests].[test log4.ExceptionHandler outputs correct ReturnMessage on null error info]
as
begin
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1;
    exec tSQLt.SpyProcedure 'log4Private.SessionInfoOutput' ;

	declare @_ErrorContext nvarchar(512) = 'Not a real error' ;
	declare @_ExpectedReturnMessage nvarchar(max) = @_ErrorContext + ' due to "ERROR_MESSAGE() Not Found for @@ERROR: NULL"';
	declare @_ActuaReturnMessage nvarchar(max);

	--! Run this without any error context
	exec log4.ExceptionHandler @ErrorContext = @_ErrorContext, @ReturnMessage = @_ActuaReturnMessage out ;

	--! Assert
	exec tSQLt.AssertEqualsString @_ExpectedReturnMessage, @_ActuaReturnMessage ;
end;