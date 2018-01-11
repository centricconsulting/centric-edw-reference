CREATE TABLE [ver].[legal_entity_holiday] (
    [legal_entity_holiday_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [legal_entity_uid]                 VARCHAR (200) NOT NULL,
    [holiday_date]                     DATE          NOT NULL,
    [holiday_name]                     VARCHAR (200) NULL,
    [source_uid]                       VARCHAR (200) NOT NULL,
    [source_rev_dtm]                   DATETIME      NOT NULL,
    [source_rev_actor]                 VARCHAR (200) NULL,
    [source_delete_ind]                BIT           NOT NULL,
    [version_dtm]                      DATETIME2 (7) NULL,
    [version_batch_key]                INT           NULL,
    CONSTRAINT [ver_legal_entity_holiday_pk] PRIMARY KEY NONCLUSTERED ([legal_entity_holiday_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_legal_entity_holiday_cx ON ver.legal_entity_holiday (legal_entity_uid, holiday_date);
GO

