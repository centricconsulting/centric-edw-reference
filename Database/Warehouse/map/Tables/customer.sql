CREATE TABLE [map].[customer] (
    [customer_key] INT           IDENTITY (100, 1) NOT NULL,
    [source_key]   INT           NOT NULL,
    [customer_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]    INT           NOT NULL,
    CONSTRAINT [dbo_customer_pk] PRIMARY KEY CLUSTERED ([customer_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dbo_customer_gx]
    ON [map].[customer]([customer_uid] ASC, [source_key] ASC);

