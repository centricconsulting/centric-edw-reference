CREATE TABLE [vex].[legal_entity_holiday] (
    [legal_entity_holiday_version_key]      INT           NOT NULL,
    [next_legal_entity_holiday_version_key] INT           NULL,
    [legal_entity_holiday_key]              INT           NULL,
    [version_index]                         INT           NULL,
    [version_current_ind]                   BIT           NULL,
    [version_latest_ind]                    BIT           NULL,
    [end_version_dtmx]                      DATETIME2 (7) NULL,
    [end_version_batch_key]                 INT           NULL,
    [end_source_rev_dtmx]                   DATETIME2 (7) NULL,
    CONSTRAINT [vex_legal_entity_holiday_pk] PRIMARY KEY CLUSTERED ([legal_entity_holiday_version_key] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [vex_legal_entity_holiday_u1]
    ON [vex].[legal_entity_holiday]([legal_entity_holiday_key] ASC) WHERE ([version_latest_ind]=(1));


GO

