CREATE TABLE [map].[invoice] (
    [invoice_key] INT           IDENTITY (100, 1) NOT NULL,
    [source_key]  INT           NOT NULL,
    [invoice_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]   INT           NOT NULL,
    CONSTRAINT [dbo_invoice_pk] PRIMARY KEY CLUSTERED ([invoice_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dbo_invoice_gx]
    ON [map].[invoice]([invoice_uid] ASC, [source_key] ASC);

