create   procedure [CommonSchemaTests].[test log4Private.SqlException column structure]
as
begin
	create table CommonSchemaTests.expected
	(
	  ExceptionId int not null
	, UtcDate datetime not null
	, SystemDate datetime not null
	, ErrorContext nvarchar(512) not null
	, ErrorNumber int not null
	, ErrorSeverity int not null
	, ErrorState int not null
	, ErrorProcedure nvarchar(128) not null
	, ErrorLine int not null
	, ErrorMessage nvarchar(max) not null
	, ErrorDatabase nvarchar(128) not null
	, SessionId int not null
	, ServerName nvarchar(128) not null
	, HostName nvarchar(128) not null
	, ProgramName nvarchar(128) not null
	, NTDomain nvarchar(128) not null
	, NTUsername nvarchar(128) not null
	, LoginName nvarchar(128) not null
	, OriginalLoginName nvarchar(128) not null
	, SessionLoginTime datetime null,
	) ;

	exec tSQLt.AssertEqualsTableSchema 'CommonSchemaTests.expected', 'log4Private.SqlException';
end;