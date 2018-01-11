CREATE TABLE [vex].[source] (
    [source_version_key]      INT           NOT NULL,
    [next_source_version_key] INT           NULL,
    [source_key]              INT           NULL,
    [version_index]           INT           NULL,
    [version_current_ind]     BIT           NULL,
    [version_latest_ind]      BIT           NULL,
    [end_version_dtmx]        DATETIME2 (7) NULL,
    [end_version_batch_key]   INT           NULL,
    [end_source_rev_dtmx]     DATETIME2 (7) NULL,
    CONSTRAINT [vex_source_pk] PRIMARY KEY CLUSTERED ([source_version_key] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [vex_source_u1]
    ON [vex].[source]([source_key] ASC) WHERE ([version_latest_ind]=(1));


GO

