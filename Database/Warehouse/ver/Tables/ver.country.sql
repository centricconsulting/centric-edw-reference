CREATE TABLE [ver].[country] (
    [country_version_key]  INT           IDENTITY (1000, 1) NOT NULL,
    [country_uid]          VARCHAR (200) NOT NULL,
    [country_code]         VARCHAR (20)  NULL,
    [country_name]         VARCHAR (200) NOT NULL,
    [world_subregion_desc] VARCHAR (200) NULL,
    [world_region_desc]    VARCHAR (200) NULL,
    [source_uid]           VARCHAR (200) NOT NULL,
    [source_rev_dtm]       DATETIME      NOT NULL,
    [source_rev_actor]     VARCHAR (200) NULL,
    [source_delete_ind]    BIT           NOT NULL,
    [version_dtm]          DATETIME2 (7) NULL,
    [version_batch_key]    INT           NULL,
    CONSTRAINT [ver_country_pk] PRIMARY KEY NONCLUSTERED ([country_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_country_cx ON ver.[country] (country_uid);
GO

