CREATE TABLE [map].[product] (
    [product_key] INT           IDENTITY (100, 1) NOT NULL,
    [source_key]  INT           NOT NULL,
    [product_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]   INT           NOT NULL,
    CONSTRAINT [dbo_product_pk] PRIMARY KEY CLUSTERED ([product_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dbo_product_gx]
    ON [map].[product]([product_uid] ASC, [source_key] ASC);

