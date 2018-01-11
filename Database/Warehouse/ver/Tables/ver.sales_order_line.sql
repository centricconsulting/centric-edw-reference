CREATE TABLE [ver].[sales_order_line] (
    [sales_order_line_version_key]        INT             IDENTITY (1000, 1) NOT NULL,
    [sales_order_lineuid]                 VARCHAR (200)   NOT NULL,
    [sales_order_uid]                     VARCHAR (200)   NULL,
    [item_uid]                            VARCHAR (200)   NULL,
    [current_sales_order_line_status_uid] VARCHAR (200)   NULL,
    [sales_order_line_desc]               VARCHAR (200)   NULL,
    [sales_order_line_index]              INT             NULL,
    [item_unit_qty]                       DECIMAL (20, 8) NULL,
    [sale_amount]                         DECIMAL (20, 8) NULL,
    [standard_cost_amount]                DECIMAL (20, 8) NULL,
    [source_uid]                          VARCHAR (200)   NOT NULL,
    [source_rev_dtm]                      DATETIME        NOT NULL,
    [source_rev_actor]                    VARCHAR (200)   NULL,
    [source_delete_ind]                   BIT             NOT NULL,
    [version_dtm]                         DATETIME2 (7)   NULL,
    [version_batch_key]                   INT             NULL,
    CONSTRAINT [ver_sales_order_line_pk] PRIMARY KEY NONCLUSTERED ([sales_order_line_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX [ver_sales_order_line_cx]
    ON [ver].[sales_order_line]([sales_order_lineuid] ASC);


GO

