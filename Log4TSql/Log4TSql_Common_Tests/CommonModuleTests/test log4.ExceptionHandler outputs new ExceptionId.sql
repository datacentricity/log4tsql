create   procedure [CommonModuleTests].[test log4.ExceptionHandler outputs new ExceptionId]
as
begin
	--! Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.SqlException', @Identity = 1;

	declare @_actual int;
	exec log4.ExceptionHandler @ErrorContext = 'Unit Test', @ExceptionId = @_actual output
	
	--! Assert
	exec tSQLt.AssertEquals 1, @_actual ;
end;