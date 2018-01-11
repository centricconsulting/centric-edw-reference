CREATE TABLE [ver].[state] (
    [state_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [state_uid]         VARCHAR (200) NOT NULL,
    [country_uid]       VARCHAR (200) NULL,
    [state_code]        VARCHAR (20)  NULL,
    [country_code]      VARCHAR (20)  NULL,
    [state_name]        VARCHAR (200) NOT NULL,
    [country_desc]      VARCHAR (200) NULL,
    [source_uid]        VARCHAR (200) NOT NULL,
    [source_rev_dtm]    DATETIME      NOT NULL,
    [source_rev_actor]  VARCHAR (200) NULL,
    [source_delete_ind] BIT           NOT NULL,
    [version_dtm]       DATETIME2 (7) NULL,
    [version_batch_key] INT           NULL,
    CONSTRAINT [ver_state_pk] PRIMARY KEY NONCLUSTERED ([state_version_key] ASC)
);


GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_state_cx ON ver.[state] (state_uid);
GO

