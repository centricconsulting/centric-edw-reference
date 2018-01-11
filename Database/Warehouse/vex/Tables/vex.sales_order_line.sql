CREATE TABLE [vex].[sales_order_line] (
    [sales_order_line_version_key]      INT           NOT NULL,
    [next_sales_order_line_version_key] INT           NULL,
    [sales_order_line_key]              INT           NULL,
    [version_index]                     INT           NULL,
    [version_current_ind]               BIT           NULL,
    [version_latest_ind]                BIT           NULL,
    [end_version_dtmx]                  DATETIME2 (7) NULL,
    [end_version_batch_key]             INT           NULL,
    [end_source_rev_dtmx]               DATETIME2 (7) NULL,
    CONSTRAINT [vex_sales_order_line_pk] PRIMARY KEY CLUSTERED ([sales_order_line_version_key] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [vex_sales_order_line_u1]
    ON [vex].[sales_order_line]([sales_order_line_key] ASC) WHERE ([version_latest_ind]=(1));


GO

