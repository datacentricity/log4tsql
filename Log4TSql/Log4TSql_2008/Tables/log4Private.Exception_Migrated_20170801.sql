CREATE TABLE [log4Private].[Exception_Migrated_20170801] (
    [ExceptionId]       INT            IDENTITY (1, 1) NOT NULL,
    [UtcDate]           DATETIME       CONSTRAINT [DF_Exception_UtcDate_Migrated] DEFAULT (getutcdate()) NOT NULL,
    [SystemDate]        DATETIME       CONSTRAINT [DF_Exception_SystemDate_Migrated] DEFAULT (getdate()) NOT NULL,
    [ErrorContext]      NVARCHAR (512) NOT NULL,
    [ErrorNumber]       INT            NOT NULL,
    [ErrorSeverity]     INT            NOT NULL,
    [ErrorState]        INT            NOT NULL,
    [ErrorProcedure]    NVARCHAR (128) NOT NULL,
    [ErrorLine]         INT            NOT NULL,
    [ErrorMessage]      NVARCHAR (MAX) NOT NULL,
    [SessionId]         INT            NOT NULL,
    [ServerName]        NVARCHAR (128) NOT NULL,
    [DatabaseName]      NVARCHAR (128) NOT NULL,
    [HostName]          NVARCHAR (128) NOT NULL,
    [ProgramName]       NVARCHAR (128) NOT NULL,
    [NTDomain]          NVARCHAR (128) NOT NULL,
    [NTUsername]        NVARCHAR (128) NOT NULL,
    [LoginName]         NVARCHAR (128) NOT NULL,
    [OriginalLoginName] NVARCHAR (128) NOT NULL,
    [SessionLoginTime]  DATETIME       NULL,
    CONSTRAINT [PK_Exception_Migrated] PRIMARY KEY NONCLUSTERED ([ExceptionId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE CLUSTERED INDEX [CI_Exception_UtcDate]
    ON [log4Private].[Exception_Migrated_20170801]([UtcDate] ASC) WITH (FILLFACTOR = 100);

