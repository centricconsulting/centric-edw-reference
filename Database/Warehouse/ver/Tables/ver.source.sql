CREATE TABLE [ver].[source] (
    [source_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [source_uid]         VARCHAR (200) NOT NULL,
    [source_name]        VARCHAR (200) NOT NULL,
    [source_code]        VARCHAR (20)  NOT NULL,
    [source_desc]        VARCHAR (200) NULL,
    [source_rev_dtm]     DATETIME      NOT NULL,
    [source_rev_actor]   VARCHAR (200) NULL,
    [source_delete_ind]  BIT           NOT NULL,
    [version_dtm]        DATETIME2 (7) NULL,
    [version_batch_key]  INT           NULL,
    CONSTRAINT [ver_source_pk] PRIMARY KEY NONCLUSTERED ([source_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_source_cx ON ver.source (source_uid);
GO

