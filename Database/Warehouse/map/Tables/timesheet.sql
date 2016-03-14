CREATE TABLE [map].[timesheet] (
    [timesheet_key]     INT           IDENTITY (100, 1) NOT NULL,
    [source_key]        INT           NOT NULL,
    [timesheet_uid]     VARCHAR (200) NOT NULL,
    [process_batch_key] INT           NOT NULL,
    CONSTRAINT [timesheet_pk] PRIMARY KEY CLUSTERED ([timesheet_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [timesheet_gx]
    ON [map].[timesheet]([source_key] ASC, [timesheet_uid] ASC);

