CREATE TABLE [map].[invoice_line] (
    [invoice_line_key] INT           IDENTITY (100, 1) NOT NULL,
    [source_key]       INT           NOT NULL,
    [invoice_line_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]        INT           NOT NULL,
    CONSTRAINT [dbo_invoice_line_pk] PRIMARY KEY CLUSTERED ([invoice_line_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dbo_invoice_line_gx]
    ON [map].[invoice_line]([invoice_line_uid] ASC, [source_key] ASC);

