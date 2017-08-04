CREATE TABLE [log4Private].[Severity] (
    [SeverityId]   INT           NOT NULL,
    [SeverityName] VARCHAR (128) NOT NULL,
    CONSTRAINT [PK_Severity] PRIMARY KEY CLUSTERED ([SeverityId] ASC),
    CONSTRAINT [UQ_Severity_SeverityName] UNIQUE NONCLUSTERED ([SeverityName] ASC)
);

