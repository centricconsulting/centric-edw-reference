CREATE TABLE [dbo].[operating_group] (
    [operating_group_key]    INT           NOT NULL,
	[operating_group_type_key] INT NOT NULL,
    [operating_group_desc]   VARCHAR (100)  NOT NULL,
    [operating_group_code]   VARCHAR (20)   NOT NULL,
[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [operating_group_pk] PRIMARY KEY CLUSTERED ([operating_group_key] ASC)
);

