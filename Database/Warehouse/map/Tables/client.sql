CREATE TABLE [map].[client] (
    [client_key]       INT    IDENTITY(100,1)       NOT NULL,
    [source_key] INT NOT NULL, 
	[client_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT        NOT NULL,
    
    CONSTRAINT [client_pk] PRIMARY KEY CLUSTERED ([client_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [client_gx]
    ON [map].[client](source_key, [client_uid] ASC);

