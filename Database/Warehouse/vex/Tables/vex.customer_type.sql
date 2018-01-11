CREATE TABLE [vex].[customer_type] (
    [customer_type_version_key]      INT           NOT NULL,
    [next_customer_type_version_key] INT           NULL,
    [customer_type_key]              INT           NULL,
    [version_index]                  INT           NULL,
    [version_current_ind]            BIT           NULL,
    [version_latest_ind]             BIT           NULL,
    [end_version_dtmx]               DATETIME2 (7) NULL,
    [end_version_batch_key]          INT           NULL,
    [end_source_rev_dtmx]            DATETIME2 (7) NULL,
    CONSTRAINT [vex_customer_type_pk] PRIMARY KEY CLUSTERED ([customer_type_version_key] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [vex_customer_type_u1]
    ON [vex].[customer_type]([customer_type_key] ASC) WHERE ([version_latest_ind]=(1));


GO

