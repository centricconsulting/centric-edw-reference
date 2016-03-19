CREATE TABLE [map].[customer_type] (
    [customer_type_key] INT           IDENTITY (100, 1) NOT NULL,
    [source_key]   INT           NOT NULL,
    [customer_type_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]    INT           NOT NULL,
    CONSTRAINT [dbo_customer_type_pk] PRIMARY KEY CLUSTERED ([customer_type_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dbo_customer_type_gx]
    ON [map].[customer_type]([customer_type_uid] ASC, [source_key] ASC);

