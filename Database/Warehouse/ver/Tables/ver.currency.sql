CREATE TABLE [ver].[currency] (
    [currency_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [currency_uid]         VARCHAR (200) NOT NULL,
    [currency_code]        VARCHAR (20)  NULL,
    [currency_name]        VARCHAR (200) NOT NULL,
    [currency_symbol]      NVARCHAR (10) NULL,
    [source_uid]           VARCHAR (200) NOT NULL,
    [source_rev_dtm]       DATETIME      NOT NULL,
    [source_rev_actor]     VARCHAR (200) NULL,
    [source_delete_ind]    BIT           NOT NULL,
    [version_dtm]          DATETIME2 (7) NULL,
    [version_batch_key]    INT           NULL,
    CONSTRAINT [ver_currency_pk] PRIMARY KEY NONCLUSTERED ([currency_version_key] ASC)
);




GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_currency_cx ON ver.currency (currency_uid);
GO

