CREATE TABLE [map].[operating_group] (
    [operating_group_key] INT      IDENTITY(100,1)   NOT NULL,
	[source_key] INT NOT NULL, 
    [operating_group_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]    INT        NOT NULL,
    CONSTRAINT [operating_group_pk] PRIMARY KEY CLUSTERED ([operating_group_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [operating_group_gx]
    ON [map].[operating_group](source_key, [operating_group_uid] ASC);

