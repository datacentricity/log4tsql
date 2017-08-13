create   procedure [CommonModuleTests].[test log4.ExceptionHandler ignores input error values]
as
begin
	exec tSQLt.FakeTable @TableName = N'log4Private.SqlException', @Identity = 1 ;

	--! Create a table to store what we expect to see
	create table #expected
	(
	  ErrorContext nvarchar(512) null
	, ErrorNumber int null
	, ErrorSeverity int null
	, ErrorState int null
	, ErrorProcedure nvarchar(128) null
	, ErrorLine int null
	, ErrorMessage nvarchar(max) null
	) ;

	declare @ErrorContext nvarchar(512) = 'Oops!' ;
	declare @NEW_LINE char(1) = char(10) ;
	declare @CreateProcedureCmd nvarchar(2000) ;

	--! Store the expected values for subsequent comparison
	insert #expected ( ErrorContext, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage )
	values ( @ErrorContext, 8134, 16, 1, 'ExceptionGenerator', 9, 'Divide by zero error encountered.' ) ;

	set @CreateProcedureCmd	= 'CREATE PROCEDURE [CommonModuleTests].[ExceptionGenerator]'
							+ @NEW_LINE + 'AS'
							+ @NEW_LINE + + 'BEGIN'
							+ @NEW_LINE + + '    SET ANSI_WARNINGS ON;'
							+ @NEW_LINE + + '    SET ARITHABORT ON;'
							+ @NEW_LINE + + ''
							+ @NEW_LINE + + '    BEGIN TRY'
							+ @NEW_LINE + + '        --! Force an exception that we can catch'
							+ @NEW_LINE + + '        DECLARE @result float; SET @result = (SELECT 1.1 / 0);'
							+ @NEW_LINE + + '    END TRY'
							+ @NEW_LINE + + '    BEGIN CATCH'
							+ @NEW_LINE + + ''
							+ @NEW_LINE + + '        EXEC log4.ExceptionHandler'
							+ @NEW_LINE + + '          @ErrorContext  = ' + coalesce('''' + @ErrorContext + '''', 'NULL')
							+ @NEW_LINE + + '        , @ErrorNumber   = 999'
							+ @NEW_LINE + + '        , @ErrorSeverity = 99'
							+ @NEW_LINE + + '        , @ErrorState    = 9999'
							+ @NEW_LINE + + '        , @ErrorLine     = 99999'
							+ @NEW_LINE + + '        , @ErrorMessage  = ''Greg woz ere!'''
							+ @NEW_LINE + + ''
							+ @NEW_LINE + + '    END CATCH'
							+ @NEW_LINE + + 'END'

	if object_id(N'[CommonModuleTests].[ExceptionGenerator]', 'P') > 0
		exec (N'drop procedure [CommonModuleTests].[ExceptionGenerator];');

	--! Create the procedure
	exec dbo.sp_executesql @CreateProcedureCmd;

	--! Now run the sproc
	exec dbo.sp_executesql N'EXEC [CommonModuleTests].[ExceptionGenerator];';

	--! Assert
	exec tSQLt.AssertEqualsTable '#expected', 'log4Private.SqlException';
end;