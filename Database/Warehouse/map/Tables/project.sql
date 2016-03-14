CREATE TABLE [map].[project_type] (
    [project_type_key]       INT           IDENTITY (100, 1) NOT NULL,
    [source_key]        INT           NOT NULL,
    [project_type_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT           NOT NULL,
    CONSTRAINT [project_type_pk] PRIMARY KEY CLUSTERED ([project_type_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [project_type_gx]
    ON [map].[project_type]([source_key] ASC, [project_type_uid] ASC);

