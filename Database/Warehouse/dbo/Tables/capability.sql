CREATE TABLE [dbo].[capability] (
    [capability_key]         INT           NOT NULL,
    [capability_desc]        VARCHAR (200) NOT NULL,
    [capability_abbr_desc]   VARCHAR (100) NULL,
    [capability_area_key]    INT           NOT NULL,
    [commercialized_flag]    CHAR (1)      NULL,
    [source_key]             INT           NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [capability_pk] PRIMARY KEY CLUSTERED ([capability_key] ASC)
);

