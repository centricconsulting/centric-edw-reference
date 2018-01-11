CREATE TABLE [ver].[legal_entity] (
    [legal_entity_version_key]  INT           IDENTITY (1000, 1) NOT NULL,
    [legal_entity_uid]          VARCHAR (200) NOT NULL,
    [parent_legal_entity_uid]   VARCHAR (200) NULL,
    [incorporation_country_uid] VARCHAR (200) NULL,
    [gl_currency_uid]           VARCHAR (200) NULL,
    [legal_entity_name]         VARCHAR (200) NOT NULL,
    [legal_entity_code]         VARCHAR (20)  NULL,
    [source_uid]                VARCHAR (200) NOT NULL,
    [source_rev_dtm]            DATETIME      NOT NULL,
    [source_rev_actor]          VARCHAR (200) NULL,
    [source_delete_ind]         BIT           NOT NULL,
    [version_dtm]               DATETIME2 (7) NULL,
    [version_batch_key]         INT           NULL,
    CONSTRAINT [ver_legal_entity_pk] PRIMARY KEY NONCLUSTERED ([legal_entity_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_legal_entity_cx ON ver.legal_entity (legal_entity_uid);
GO

