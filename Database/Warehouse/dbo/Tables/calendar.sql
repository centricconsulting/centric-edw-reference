/*
##################################################################
Note that the Date keys are smart keys of the form YYYYMMDD.

Smart keys  are generally forbidden in the architecture, however
we use them for Dates and Fiscal Periods due to their consistently
understood meaning and presumed zero of risk that values may
come from anywhere other than our manual control.  
##################################################################
*/


CREATE TABLE dbo.calendar (
  date_key int NOT NULL
, [date] date NULL
, day_of_week int NULL
, day_of_month int NULL
, day_of_quarter int NULL
, day_of_year int NULL
, day_desc_01 varchar(20) NULL
, day_desc_02 varchar(20) NULL
, day_desc_03 varchar(20) NULL
, day_desc_04 varchar(20) NULL
, weekday_desc_01 varchar(20) NULL
, weekday_desc_02 varchar(20) NULL

, day_weekdays int NULL
, day_workdays int NULL

, week_key int NULL
, week_begin_dt date NULL
, week_end_dt date NULL
, week_desc_01 varchar(20) NULL
, week_desc_02 varchar(20) NULL
, week_desc_03 varchar(20) NULL
, week_desc_04 varchar(20) NULL
, week_days int NULL
, week_weekdays int NULL
, week_workdays int NULL

, month_key int NULL
, month_begin_dt date NULL
, month_end_dt date NULL
, month_of_quarter int NULL
, month_of_year int NULL
, month_desc_01 varchar(20) NULL
, month_desc_02 varchar(20) NULL
, month_desc_03 varchar(20) NULL
, month_desc_04 varchar(20) NULL
, month_of_year_desc_01 varchar(20) NULL
, month_of_year_desc_02 varchar(20) NULL

, month_days int NULL
, month_weekdays int NULL
, month_workdays int NULL

, quarter_key int NULL
, quarter_begin_dt date NULL
, quarter_end_dt date NULL
, quarter_of_year int NULL
, quarter_desc_01 varchar(20) NULL
, quarter_desc_02 varchar(20) NULL
, quarter_desc_03 varchar(50) NULL
, quarter_desc_04 varchar(50) NULL
, quarter_of_year_desc_01 varchar(20) NULL
, quarter_of_year_desc_02 varchar(20) NULL

, quarter_days int NULL
, quarter_weekdays int NULL
, quarter_workdays int NULL
, quarter_months int NULL

, year_key int NULL
, [year] int NULL
, year_begin_dt date NULL
, year_end_dt date NULL
, year_desc_01 varchar(20) NULL
, year_desc_02 varchar(20) NULL

, year_days int NULL
, year_weekdays int NULL
, year_workdays int NULL
, year_months int NULL
, year_quarters int NULL

, day_index int NULL
, week_index int NULL
, month_index int NULL
, quarter_index int NULL
, year_index int NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT calendar_pk PRIMARY KEY (date_key)
);