CREATE TABLE [dbo].[project_stage] (
    [project_stage_key]      INT           NOT NULL,
    [project_stage_desc]     VARCHAR (100) NOT NULL,
    [won_project_flag]       CHAR (1)      NULL,
    [sort_order]             INT           NULL,
    [source_key]             INT           NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [project_stage_pk] PRIMARY KEY CLUSTERED ([project_stage_key] ASC)
);



