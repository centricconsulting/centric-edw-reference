CREATE TABLE [cube].[ops_timesheet] (
    [project_key]                  INT              NOT NULL,
    [resource_key]                 INT              NOT NULL,
    [bill_date_key]                INT              NOT NULL,
    [client_key]                   INT              NOT NULL,
    [operating_group_key]          INT              NOT NULL,
    [resource_operating_group_key] INT              NOT NULL,
    [Charge Flag]                  VARCHAR (20)     NOT NULL,
    [base_report_hours]            DECIMAL (20, 12) NULL,
    [base_work_hours]              DECIMAL (20, 12) NULL,
    [base_nonwork_hours]           DECIMAL (20, 12) NULL,
    [base_charge_hours]            DECIMAL (20, 12) NULL,
    [base_noncharge_hours]         DECIMAL (20, 12) NULL,
    [base_timesheet_revenue]       MONEY            NULL,
    [base_available_hours]         DECIMAL (20, 12) NULL
);

