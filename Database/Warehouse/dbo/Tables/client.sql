CREATE TABLE [dbo].[client] (
    [client_key]             INT           NOT NULL,
    [client_desc]            VARCHAR (200) NULL,
	[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [client_pk] PRIMARY KEY CLUSTERED ([client_key] ASC)
);

