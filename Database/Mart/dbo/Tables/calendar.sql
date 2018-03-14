﻿CREATE TABLE [dbo].[calendar] (
    [date_key]                  INT          NOT NULL,
    [date]                      DATE         NULL,
    [day_of_week]               INT          NULL,
    [day_of_month]              INT          NULL,
    [day_of_quarter]            INT          NULL,
    [day_of_year]               INT          NULL,
    [day_desc_01]               VARCHAR (20) NULL,
    [day_desc_02]               VARCHAR (20) NULL,
    [day_desc_03]               VARCHAR (20) NULL,
    [day_desc_04]               VARCHAR (20) NULL,
    [weekday_desc_01]           VARCHAR (20) NULL,
    [weekday_desc_02]           VARCHAR (20) NULL,
    [day_weekday_count]            VARCHAR (20) NULL,
    [week_key]                  INT          NULL,
    [week_start_date]             DATE         NULL,
    [week_end_date]               DATE         NULL,
    [week_day_count]               INT          NULL,
    [week_weekday_count]           INT          NULL,
    [month_key]                 INT          NULL,
    [month_start_date]            DATE         NULL,
    [month_end_date]              DATE         NULL,
    [month_of_quarter]          INT          NULL,
    [month_of_year]             INT          NULL,
    [month_desc_01]             VARCHAR (20) NULL,
    [month_desc_02]             VARCHAR (20) NULL,
    [month_desc_03]             VARCHAR (20) NULL,
    [month_desc_04]             VARCHAR (20) NULL,
    [month_day_count]              INT          NULL,
    [month_weekday_count]          INT          NULL,
    [quarter_key]               INT          NULL,
    [quarter_start_date]          DATE         NULL,
    [quarter_end_date]            DATE         NULL,
    [quarter_of_year]           INT          NULL,
    [quarter_desc_01]           VARCHAR (20) NULL,
    [quarter_desc_02]           VARCHAR (20) NULL,
    [quarter_desc_03]           VARCHAR (50) NULL,
    [quarter_desc_04]           VARCHAR (50) NULL,
    [quarter_month_count]          INT          NULL,
    [quarter_day_count]            INT          NULL,
    [quarter_weekday_count]        INT          NULL,
    [year_key]                  INT          NULL,
    [year]                      INT          NULL,
    [year_start_date]             DATE         NULL,
    [year_end_date]               DATE         NULL,
    [year_desc_01]              VARCHAR (20) NULL,
    [year_month_count]             INT          NULL,
    [year_quarter_count]           INT          NULL,
    [year_day_count]               INT          NULL,
    [year_weekday_count]           INT          NULL,
    day_index INT NULL,
    week_index INT NULL,
    month_index INT NULL,
    quarter_index INT NULL,
    year_index INT NULL,

    CONSTRAINT dbo_calendar_pk PRIMARY KEY (date_key)
);

