CREATE TABLE [map].[resource_type] (
    [resource_type_key]     INT     IDENTITY(100,1)      NOT NULL,
	[source_key] INT NOT NULL, 
    [resource_type_uid]     VARCHAR (200) NOT NULL,
    [process_batch_key] INT        NOT NULL,
    CONSTRAINT [resource_type_pk] PRIMARY KEY CLUSTERED ([resource_type_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [resource_type_gx]
    ON [map].[resource_type](source_key, [resource_type_uid] ASC);

