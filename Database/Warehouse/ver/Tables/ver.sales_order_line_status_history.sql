CREATE TABLE [ver].[sales_order_line_status_history] (
    [sales_order_line_status_history_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [sales_order_line_uid]                        VARCHAR (200) NOT NULL,
    [status_date]                                 DATE          NOT NULL,
    [sales_order_line_status_uid]                 VARCHAR (200) NULL,
    [status_comment_desc]                         VARCHAR (200) NULL,
    [source_uid]                                  VARCHAR (200) NOT NULL,
    [source_rev_dtm]                              DATETIME      NOT NULL,
    [source_rev_actor]                            VARCHAR (200) NULL,
    [source_delete_ind]                           BIT           NOT NULL,
    [version_dtm]                                 DATETIME2 (7) NULL,
    [version_batch_key]                           INT           NULL,
    CONSTRAINT [ver_sales_order_line_status_history_pk] PRIMARY KEY NONCLUSTERED ([sales_order_line_status_history_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_sales_order_line_status_history_cx ON ver.sales_order_line_status_history (sales_order_line_uid, status_date);
GO

