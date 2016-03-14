CREATE TABLE [map].[gl_tran] (
    [gl_tran_key]       INT    IDENTITY(100,1)       NOT NULL,
    [source_key] INT NOT NULL, 
	[gl_tran_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT        NOT NULL,
    
    CONSTRAINT [gl_tran_pk] PRIMARY KEY CLUSTERED ([gl_tran_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [gl_tran_gx]
    ON [map].[gl_tran](source_key, [gl_tran_uid] ASC);

