CREATE TABLE [map].[project_resource_book] (
    [project_resource_book_key]       INT           IDENTITY (100, 1) NOT NULL,
    [source_key]        INT           NOT NULL,
    [project_resource_book_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT           NOT NULL,
    CONSTRAINT [project_resource_book_pk] PRIMARY KEY CLUSTERED ([project_resource_book_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [project_resource_book_gx]
    ON [map].[project_resource_book]([source_key] ASC, [project_resource_book_uid] ASC);

