set nocount on
go

IF NOT EXISTS (SELECT 1 FROM [log4].[JournalControl] WHERE ModuleName = 'SYSTEM_DEFAULT')
	INSERT [log4].[JournalControl]([ModuleName], [OnOffSwitch]) VALUES('SYSTEM_DEFAULT', 'ON')
ELSE
	UPDATE [log4].[JournalControl] SET OnOffSwitch = 'ON' WHERE ModuleName = 'SYSTEM_DEFAULT'
GO

IF NOT EXISTS (SELECT 1 FROM [log4].[JournalControl] WHERE ModuleName = 'SYSTEM_OVERRIDE')
	INSERT [log4].[JournalControl]([ModuleName], [OnOffSwitch]) VALUES('SYSTEM_OVERRIDE', 'ON')
ELSE
	UPDATE [log4].[JournalControl] SET OnOffSwitch = 'ON' WHERE ModuleName = 'SYSTEM_OVERRIDE'
GO

set nocount off
go
