CREATE TABLE [dbo].[calendar] (
    [date_key]             INT          NOT NULL,
    [date]                 DATE         NULL,
    [utility_hours]        INT          CONSTRAINT [df_calendar_util_hrs] DEFAULT ((0)) NOT NULL,
    [day_of_week]          INT          NULL,
    [day_of_month]         INT          NULL,
    [day_of_quarter]       INT          NULL,
    [day_of_year]          INT          NULL,
    [day_desc_01]          VARCHAR (20) NULL,
    [day_desc_02]          VARCHAR (20) NULL,
    [day_desc_03]          VARCHAR (20) NULL,
    [day_desc_04]          VARCHAR (20) NULL,
    [weekday_desc_01]      VARCHAR (20) NULL,
    [weekday_desc_02]      VARCHAR (20) NULL,
    [day_weekday_ct]       INT          NULL,
    [week_key]             INT          NULL,
    [week_start_dt]        DATE         NULL,
    [week_end_dt]          DATE         NULL,
    [week_day_ct]          INT          NULL,
    [week_weekday_ct]      INT          NULL,
    [week_desc_01]         VARCHAR (20) NULL,
    [week_desc_02]         VARCHAR (20) NULL,
    [week_desc_03]         VARCHAR (20) NULL,
    [month_key]            INT          NULL,
    [month_start_dt]       DATE         NULL,
    [month_end_dt]         DATE         NULL,
    [month_of_quarter]     INT          NULL,
    [month_of_year]        INT          NULL,
    [month_desc_01]        VARCHAR (20) NULL,
    [month_desc_02]        VARCHAR (20) NULL,
    [month_desc_03]        VARCHAR (20) NULL,
    [month_desc_04]        VARCHAR (20) NULL,
    [month_day_ct]         INT          NULL,
    [month_weekday_ct]     INT          NULL,
    [quarter_key]          INT          NULL,
    [quarter_start_dt]     DATE         NULL,
    [quarter_end_dt]       DATE         NULL,
    [quarter_of_year]      INT          NULL,
    [quarter_desc_01]      VARCHAR (20) NULL,
    [quarter_desc_02]      VARCHAR (20) NULL,
    [quarter_desc_03]      VARCHAR (50) NULL,
    [quarter_desc_04]      VARCHAR (50) NULL,
    [quarter_month_ct]     INT          NULL,
    [quarter_day_ct]       INT          NULL,
    [quarter_weekday_ct]   INT          NULL,
    [year_key]             INT          NULL,
    [year]                 INT          NULL,
    [year_start_dt]        DATE         NULL,
    [year_end_dt]          DATE         NULL,
    [year_desc_01]         VARCHAR (20) NULL,
    [year_month_ct]        INT          NULL,
    [year_quarter_ct]      INT          NULL,
    [year_day_ct]          INT          NULL,
    [year_weekday_ct]      INT          NULL,
    [date_index]           INT          NULL,
    [week_index]           INT          NULL,
    [month_index]          INT          NULL,
    [quarter_index]        INT          NULL,
    [year_index]           INT          NULL,
    [closed_year_index]    INT          NULL,
    [closed_quarter_index] INT          NULL,
    [closed_month_index]   INT          NULL,
    [process_batch_key]    INT          NOT NULL,
    [workday_index]        INT          NULL,
    [next_workday_index]   INT          NULL,
    CONSTRAINT [calendar_pk] PRIMARY KEY CLUSTERED ([date_key] ASC)
);










GO


