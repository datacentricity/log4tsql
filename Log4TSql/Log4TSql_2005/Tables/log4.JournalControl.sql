CREATE TABLE [log4].[JournalControl] (
    [ModuleName]  VARCHAR (255) NOT NULL,
    [OnOffSwitch] VARCHAR (3)   NOT NULL,
    CONSTRAINT [PK_JournalControl] PRIMARY KEY NONCLUSTERED ([ModuleName] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_JournalControl_OnOffSwitch] CHECK ([OnOffSwitch]='OFF' OR [OnOffSwitch]='ON')
);


GO
CREATE CLUSTERED INDEX [CI_JournalControl_ModuleName]
    ON [log4].[JournalControl]([ModuleName] ASC) WITH (FILLFACTOR = 100);

