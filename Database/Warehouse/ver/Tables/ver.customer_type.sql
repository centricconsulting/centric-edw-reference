CREATE TABLE [ver].[customer_type] (
    [customer_type_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [customer_type_uid]         VARCHAR (200) NOT NULL,
    [customer_type_name]        VARCHAR (200) NOT NULL,
    [customer_type_code]        VARCHAR (20)  NULL,
    [source_uid]                VARCHAR (200) NOT NULL,
    [source_rev_dtm]            DATETIME      NOT NULL,
    [source_rev_actor]          VARCHAR (200) NULL,
    [source_delete_ind]         BIT           NOT NULL,
    [version_dtm]               DATETIME2 (7) NULL,
    [version_batch_key]         INT           NULL,
    CONSTRAINT [ver_customer_type_pk] PRIMARY KEY NONCLUSTERED ([customer_type_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_customer_type_cx ON ver.customer_type (customer_type_uid);
GO

