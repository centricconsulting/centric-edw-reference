CREATE TABLE [dbo].[project_capability] (
    [project_key]            INT              NOT NULL,
    [capability_key]         INT              NOT NULL,
    [involvement_level]      VARCHAR (50)     NULL,
    [allocation_rate]        DECIMAL (20, 12) NULL,
    [source_key]             INT              NOT NULL,
    [source_revision_dtm]    DATETIME         NOT NULL,
    [source_revision_actor]  VARCHAR (200)    NULL,
    [init_process_batch_key] INT              NOT NULL,
    [process_batch_key]      INT              NOT NULL,
    CONSTRAINT [project_capability_pk] PRIMARY KEY CLUSTERED ([project_key] ASC, [capability_key] ASC)
);

