CREATE TABLE [map].[operating_group_type] (
    [operating_group_type_key]       INT    IDENTITY(100,1)    NOT NULL ,
    [source_key] INT NOT NULL, 
	[operating_group_type_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT        NOT NULL,
    
    CONSTRAINT [operating_group_type_pk] PRIMARY KEY CLUSTERED ([operating_group_type_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [operating_group_type_gx]
    ON [map].[operating_group_type](source_key, [operating_group_type_uid] ASC);

