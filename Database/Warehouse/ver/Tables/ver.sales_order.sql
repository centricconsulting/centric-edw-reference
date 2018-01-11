CREATE TABLE [ver].[sales_order] (
    [sales_order_version_key]  INT             IDENTITY (1000, 1) NOT NULL,
    [sales_order_uid]          VARCHAR (200)   NOT NULL,
    [revenue_legal_entity_uid] VARCHAR (200)   NULL,
    [customer_uid]             VARCHAR (200)   NULL,
    [sales_order_date]         DATE            NULL,
    [sales_order_number]       VARCHAR (100)   NULL,
    [tax_amount]               DECIMAL (20, 8) NULL,
    [freight_amount]           DECIMAL (20, 8) NULL,
    [source_uid]               VARCHAR (200)   NOT NULL,
    [source_rev_dtm]           DATETIME        NOT NULL,
    [source_rev_actor]         VARCHAR (200)   NULL,
    [source_delete_ind]        BIT             NOT NULL,
    [version_dtm]              DATETIME2 (7)   NULL,
    [version_batch_key]        INT             NULL,
    CONSTRAINT [ver_sales_order_pk] PRIMARY KEY NONCLUSTERED ([sales_order_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_sales_order_cx ON ver.sales_order (sales_order_uid);
GO

