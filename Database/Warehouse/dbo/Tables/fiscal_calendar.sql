/*
##################################################################
Note that the Fiscal Period keys are smart keys of the form YYYYMM.
Note that the Date keys are smart keys of the form YYYYMMDD.

Smart keys  are generally forbidden in the architecture, however
we use them for Dates and Fiscal Periods due to their consistently
understood meaning and presumed zero of risk that date values may
come from anywhere other than our manual control.  
##################################################################
*/

CREATE TABLE [dbo].[fiscal_calendar]
(
  date_key int NOT NULL

, fiscal_day_of_week int NULL
, fiscal_day_of_period int NULL
, fiscal_day_of_quarter int NULL
, fiscal_day_of_year int NULL

, fiscal_week_key int NULL
, fiscal_week_begin_dt date NULL
, fiscal_week_end_dt date NULL
, fiscal_week_desc_01 varchar(20) NULL
, fiscal_week_desc_02 varchar(20) NULL
, fiscal_week_desc_03 varchar(20) NULL
, fiscal_week_desc_04 varchar(20) 
, fiscal_week_days int NULL
, fiscal_week_weekdays int NULL
, fiscal_week_workdays int NULL

, fiscal_period_key int NULL
, fiscal_period_begin_dt date NULL
, fiscal_period_end_dt date NULL
, fiscal_period_of_quarter int NULL
, fiscal_period_of_year int NULL
, fiscal_period_desc_01 varchar(20) NULL
, fiscal_period_desc_02 varchar(20) NULL
, fiscal_period_desc_03 varchar(20) NULL
, fiscal_period_desc_04 varchar(20) NULL
, fiscal_period_of_year_desc_01 varchar(20) NULL
, fiscal_period_of_year_desc_02 varchar(20) NULL
, fiscal_period_closed_ind smallint
, fiscal_period_days int NULL
, fiscal_period_weekdays int NULL
, fiscal_period_workdays int NULL

, fiscal_quarter_key int NULL
, fiscal_quarter_begin_dt date NULL
, fiscal_quarter_end_dt date NULL
, fiscal_quarter_of_year int NULL
, fiscal_quarter_desc_01 varchar(20) NULL
, fiscal_quarter_desc_02 varchar(20) NULL
, fiscal_quarter_desc_03 varchar(50) NULL
, fiscal_quarter_desc_04 varchar(50) NULL
, fiscal_quarter_periods int NULL
, fiscal_quarter_of_year_desc_01 varchar(20) NULL
, fiscal_quarter_of_year_desc_02 varchar(20) NULL

, fiscal_quarter_days int NULL
, fiscal_quarter_weekdays int NULL
, fiscal_quarter_workdays int NULL

, fiscal_year_key int NULL
, fiscal_year int NULL
, fiscal_year_begin_dt date NULL
, fiscal_year_end_dt date NULL
, fiscal_year_desc_01 varchar(20) NULL
, fiscal_year_desc_02 varchar(20) NULL
, fiscal_year_periods int NULL
, fiscal_year_quarters int NULL
, fiscal_year_days int NULL
, fiscal_year_weekdays int NULL
, fiscal_year_workdays int NULL
, fiscal_year_closed_ind smallint

, fiscal_week_index int NULL
, fiscal_period_index int NULL
, closed_fiscal_period_index int NULL
, fiscal_quarter_index int NULL
, fiscal_year_index int NULL
, closed_fiscal_year_index int NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT fiscal_calendar_pk PRIMARY KEY (date_key)
);