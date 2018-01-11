CREATE TABLE [ver].[legal_entity_fiscal_period] (
    [legal_entity_fiscal_period_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [legal_entity_uid]                       VARCHAR (200) NOT NULL,
    [fiscal_year]                            INT           NOT NULL,
    [fiscal_period_of_year_index]            INT           NOT NULL,
    [begin_fiscal_period_date]               DATE          NOT NULL,
    [end_fiscal_period_date]                 DATE          NULL,
    [display_month_of_year]                  INT           NOT NULL,
    [source_uid]                             VARCHAR (200) NOT NULL,
    [source_rev_dtm]                         DATETIME      NOT NULL,
    [source_rev_actor]                       VARCHAR (200) NULL,
    [source_delete_ind]                      BIT           NOT NULL,
    [version_dtm]                            DATETIME2 (7) NULL,
    [version_batch_key]                      INT           NULL,
    CONSTRAINT [ver_legal_entity_fiscal_period_pk] PRIMARY KEY NONCLUSTERED ([legal_entity_fiscal_period_version_key] ASC)
);




GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX [ver_legal_entity_fiscal_period_cx]
    ON [ver].[legal_entity_fiscal_period]([legal_entity_uid] ASC, [fiscal_year] ASC, [fiscal_period_of_year_index] ASC);




GO

