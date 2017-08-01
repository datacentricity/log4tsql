CREATE TABLE [log4].[Journal] (
    [JournalId]         INT            IDENTITY (1, 1) NOT NULL,
    [UtcDate]           DATETIME       CONSTRAINT [DF_Journal_UtcDate] DEFAULT (getutcdate()) NOT NULL,
    [SystemDate]        DATETIME       CONSTRAINT [DF_Journal_SystemDate] DEFAULT (getdate()) NOT NULL,
    [Task]              VARCHAR (128)  CONSTRAINT [DF_Journal_Task] DEFAULT ('') NOT NULL,
    [FunctionName]      VARCHAR (256)  NOT NULL,
    [StepInFunction]    VARCHAR (128)  NOT NULL,
    [MessageText]       VARCHAR (512)  NOT NULL,
    [SeverityId]        INT            NOT NULL,
    [ExceptionId]       INT            NULL,
    [SessionId]         INT            NOT NULL,
    [ServerName]        NVARCHAR (128) NOT NULL,
    [DatabaseName]      NVARCHAR (128) NOT NULL,
    [HostName]          NVARCHAR (128) NULL,
    [ProgramName]       NVARCHAR (128) NULL,
    [NTDomain]          NVARCHAR (128) NULL,
    [NTUsername]        NVARCHAR (128) NULL,
    [LoginName]         NVARCHAR (128) NULL,
    [OriginalLoginName] NVARCHAR (128) NULL,
    [SessionLoginTime]  DATETIME       NULL,
    CONSTRAINT [PK_Journal] PRIMARY KEY NONCLUSTERED ([JournalId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Journal_Exception] FOREIGN KEY ([ExceptionId]) REFERENCES [log4].[Exception] ([ExceptionId]),
    CONSTRAINT [FK_Journal_Severity] FOREIGN KEY ([SeverityId]) REFERENCES [log4].[Severity] ([SeverityId])
);


GO
CREATE CLUSTERED INDEX [CI_Journal_SystemDate]
    ON [log4].[Journal]([SystemDate] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NCI_Journal_FunctionName_Severity]
    ON [log4].[Journal]([FunctionName] ASC, [SeverityId] ASC) WITH (FILLFACTOR = 80);

