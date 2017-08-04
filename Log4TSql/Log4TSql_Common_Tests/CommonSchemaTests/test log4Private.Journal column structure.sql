create   procedure [CommonSchemaTests].[test log4Private.Journal column structure]
as
begin
	create table CommonSchemaTests.expected
	(
	  JournalId int not null
	, UtcDate datetime not null
	, SystemDate datetime not null
	, Task varchar(128) not null
	, FunctionName varchar(256) not null
	, StepInFunction varchar(128) not null
	, MessageText varchar(512) not null
	, SeverityId int not null
	, ExceptionId int null
	, SessionId int not null
	, ServerName nvarchar(128) not null
	, DatabaseName nvarchar(128) not null
	, HostName nvarchar(128) null
	, ProgramName nvarchar(128) null
	, NTDomain nvarchar(128) null
	, NTUsername nvarchar(128) null
	, LoginName nvarchar(128) null
	, OriginalLoginName nvarchar(128) null
	, SessionLoginTime datetime null,
	) ;

	exec tSQLt.AssertEqualsTableSchema 'CommonSchemaTests.expected', 'log4Private.Journal';
end;