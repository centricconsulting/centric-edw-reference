CREATE TABLE [dbo].[source] (
    [source_key]       INT        NOT NULL,
    [source_name]      VARCHAR (50)  NOT NULL,
    [source_desc]      VARCHAR (100) NULL,
    [process_batch_key] INT        NOT NULL,
    CONSTRAINT [source_pk] PRIMARY KEY CLUSTERED ([source_key] ASC)
);

