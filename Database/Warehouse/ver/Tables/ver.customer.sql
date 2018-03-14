CREATE TABLE [ver].[customer] (
    [customer_version_key]     INT              IDENTITY (1000, 1) NOT NULL,
    [customer_uid]             VARCHAR (200)    NOT NULL,
    [customer_legal_name]      VARCHAR (200)    NOT NULL,
    [parent_organization_name] VARCHAR (200)    NOT NULL,
    [customer_nbr]             VARCHAR (50)     NULL,
    [risk_score_val]           DECIMAL (20, 12) NULL,
    [source_uid]               VARCHAR (200)    NOT NULL,
    [source_rev_dtm]           DATETIME         NOT NULL,
    [source_rev_actor]         VARCHAR (200)    NULL,
    [source_delete_ind]        BIT              NOT NULL,
    [version_dtm]              DATETIME2 (7)    NULL,
    [version_batch_key]        INT              NULL,
    CONSTRAINT [ver_customer_pk] PRIMARY KEY NONCLUSTERED ([customer_version_key] ASC)
);




GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_customer_cx ON ver.customer (customer_uid);
GO
