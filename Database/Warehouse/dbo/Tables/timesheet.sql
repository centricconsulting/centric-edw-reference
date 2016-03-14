CREATE TABLE [dbo].[timesheet] (
    [timesheet_key]          INT            NOT NULL,
    [project_key]            INT            NOT NULL,
    [resource_key]           INT            NOT NULL,
    [client_key]             INT            NOT NULL,
    [bill_date_key]          INT            NOT NULL,
    [bill_hours]             DECIMAL (4, 2) NOT NULL,
    [bill_rate]              DECIMAL (7, 2) NOT NULL,
    [timesheet_revenue]      DECIMAL (8, 2) NOT NULL,
    charge_hours      DECIMAL (4, 2) NULL,
    [task_desc]              VARCHAR (4000) NULL,
    [chargeable_flag]        CHAR (1)       NOT NULL,
    [source_key]             INT            NOT NULL,
    [source_revision_dtm]    DATETIME       NOT NULL,
    [source_revision_actor]  VARCHAR (200)  NULL,
    [init_process_batch_key] INT            NOT NULL,
    [process_batch_key]      INT            NOT NULL,
    CONSTRAINT [timesheet_pk] PRIMARY KEY CLUSTERED ([timesheet_key] ASC)
);







