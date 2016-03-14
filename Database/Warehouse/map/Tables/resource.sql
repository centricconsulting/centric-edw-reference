CREATE TABLE [map].[resource] (
    [resource_key]     INT     IDENTITY(100,1)      NOT NULL,
	[source_key] INT NOT NULL, 
    [resource_uid]     VARCHAR (200) NOT NULL,
    [process_batch_key] INT        NOT NULL,
    CONSTRAINT [resource_pk] PRIMARY KEY CLUSTERED ([resource_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [resource_gx]
    ON [map].[resource](source_key, [resource_uid] ASC);

