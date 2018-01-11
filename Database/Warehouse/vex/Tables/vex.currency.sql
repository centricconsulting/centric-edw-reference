CREATE TABLE [vex].[currency] (
    [currency_version_key]      INT           NOT NULL,
    [next_currency_version_key] INT           NULL,
    [currency_key]              INT           NULL,
    [version_index]             INT           NULL,
    [version_current_ind]       BIT           NULL,
    [version_latest_ind]        BIT           NULL,
    [end_version_dtmx]          DATETIME2 (7) NULL,
    [end_version_batch_key]     INT           NULL,
    [end_source_rev_dtmx]       DATETIME2 (7) NULL,
    CONSTRAINT [vex_currency_pk] PRIMARY KEY CLUSTERED ([currency_version_key] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [vex_currency_u1]
    ON [vex].[currency]([currency_key] ASC) WHERE ([version_latest_ind]=(1));


GO

