﻿CREATE TABLE [map].[source] (
    [source_key]       INT  NOT NULL,
    [source_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT        NOT NULL,
    CONSTRAINT [dbo_source_pk] PRIMARY KEY CLUSTERED ([source_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dbo_source_gx]
    ON [map].[source]([source_uid] ASC);

