CREATE TABLE [map].[capability] (
    [capability_key]    INT           IDENTITY (100, 1) NOT NULL,
    [source_key]        INT           NOT NULL,
    [capability_uid]    VARCHAR (200) NOT NULL,
    [process_batch_key] INT           NOT NULL,
    CONSTRAINT [capability_pk] PRIMARY KEY CLUSTERED ([capability_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [capability_gx]
    ON [map].[capability]([source_key] ASC, [capability_key] ASC);

