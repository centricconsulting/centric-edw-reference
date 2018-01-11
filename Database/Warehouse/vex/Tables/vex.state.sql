CREATE TABLE [vex].[state] (
    [state_version_key]      INT           NOT NULL,
    [next_state_version_key] INT           NULL,
    [state_key]              INT           NULL,
    [version_index]          INT           NULL,
    [version_current_ind]    BIT           NULL,
    [version_latest_ind]     BIT           NULL,
    [end_version_dtmx]       DATETIME2 (7) NULL,
    [end_version_batch_key]  INT           NULL,
    [end_source_rev_dtmx]    DATETIME2 (7) NULL,
    CONSTRAINT [vex_state_pk] PRIMARY KEY CLUSTERED ([state_version_key] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [vex_state_u1]
    ON [vex].[state]([state_key] ASC) WHERE ([version_latest_ind]=(1));


GO

