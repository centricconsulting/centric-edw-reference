CREATE TABLE [ver].[customer_xref] (
    [customer_xref_version_key] INT           IDENTITY (1000, 1) NOT NULL,
    [customer_uid]              VARCHAR (200) NOT NULL,
    [master_customer_uid]       VARCHAR (200) NULL,
    [source_uid]                VARCHAR (200) NOT NULL,
    [source_rev_dtm]            DATETIME      NOT NULL,
    [source_rev_actor]          VARCHAR (200) NULL,
    [source_delete_ind]         BIT           NOT NULL,
    [version_dtm]               DATETIME2 (7) NULL,
    [version_batch_key]         INT           NULL,
    CONSTRAINT [ver_customer_xref_pk] PRIMARY KEY NONCLUSTERED ([customer_xref_version_key] ASC)
);


GO
CREATE CLUSTERED INDEX [ver_customer_xref_cx]
    ON [ver].[customer_xref]([customer_uid] ASC);

