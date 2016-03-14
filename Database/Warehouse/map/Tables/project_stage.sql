CREATE TABLE [map].[project_stage] (
    [project_stage_key]       INT           IDENTITY (100, 1) NOT NULL,
    [source_key]        INT           NOT NULL,
    [project_stage_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT           NOT NULL,
    CONSTRAINT [project_stage_pk] PRIMARY KEY CLUSTERED ([project_stage_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [project_stage_gx]
    ON [map].[project_stage]([source_key] ASC, [project_stage_uid] ASC);

