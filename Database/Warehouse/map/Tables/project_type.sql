CREATE TABLE [map].[project] (
    [project_key]       INT           IDENTITY (100, 1) NOT NULL,
    [source_key]        INT           NOT NULL,
    [project_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT           NOT NULL,
    CONSTRAINT [project_pk] PRIMARY KEY CLUSTERED ([project_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [project_gx]
    ON [map].[project]([source_key] ASC, [project_uid] ASC);

