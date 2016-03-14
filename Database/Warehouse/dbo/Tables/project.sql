CREATE TABLE [dbo].[project] (
    [project_key]               INT           NOT NULL,
    [client_key]                INT           NOT NULL,
    [operating_group_key]       INT           NOT NULL,
    [current_project_stage_key] INT           NOT NULL,
    [project_type_key]          INT           NOT NULL,
    [project_desc]              VARCHAR (200) NULL,
    [internal_flag]             CHAR (1)      NULL,
    [source_key]                INT           NOT NULL,
    [source_revision_dtm]       DATETIME      NOT NULL,
    [source_revision_actor]     VARCHAR (200) NULL,
    [init_process_batch_key]    INT           NOT NULL,
    [process_batch_key]         INT           NOT NULL,
    CONSTRAINT [project_pk] PRIMARY KEY CLUSTERED ([project_key] ASC)
);



