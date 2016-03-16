CREATE TABLE dbo.calendar (
  date_key int NOT NULL
, source_key int NOT NULL
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
, day_weekdays varchar(20) NULL

, week_key int NULL
, week_start_dt date NULL
, week_end_dt date NULL
, week_days int NULL
, week_weekdays int NULL

, month_key int NULL
, month_start_dt date NULL
, month_end_dt date NULL
, month_of_quarter int NULL
, month_of_year int NULL
, month_desc_01 varchar(20) NULL
, month_desc_02 varchar(20) NULL
, month_desc_03 varchar(20) NULL
, month_desc_04 varchar(20) NULL
, month_days int NULL
, month_weekdays int NULL

, quarter_key int NULL
, quarter_start_dt date NULL
, quarter_end_dt date NULL
, quarter_of_year int NULL
, quarter_desc_01 varchar(20) NULL
, quarter_desc_02 varchar(20) NULL
, quarter_desc_03 varchar(50) NULL
, quarter_desc_04 varchar(50) NULL
, quarter_months int NULL
, quarter_days int NULL
, quarter_weekdays int NULL

, year_key int NULL
, [year] int NULL
, year_start_dt date NULL
, year_end_dt date NULL
, year_desc_01 varchar(20) NULL
, year_months int NULL
, year_quarters int NULL
, year_days int NULL
, year_weekdays int NULL

, fiscal_day_of_period int NULL
, fiscal_day_of_quarter int NULL
, fiscal_day_of_year int NULL
, fiscal_day_weekdays int NULL

, fiscal_week_key int NULL
, fiscal_week_start_dt date NULL
, fiscal_week_end_dt date NULL
, fiscal_week_desc_01 varchar(20) NULL
, fiscal_week_desc_02 varchar(20) NULL
, fiscal_week_days int NULL
, fiscal_week_weekdays int NULL

, fiscal_period_key int NULL
, fiscal_period_start_dt date NULL
, fiscal_period_end_dt date NULL
, fiscal_period_of_quarter int NULL
, fiscal_period_of_year int NULL
, fiscal_period_desc_01 varchar(20) NULL
, fiscal_period_desc_02 varchar(20) NULL
, fiscal_period_desc_03 varchar(20) NULL
, fiscal_period_desc_04 varchar(20) NULL
, fiscal_period_days int NULL
, fiscal_period_weekdays int NULL

, fiscal_quarter_key int NULL
, fiscal_quarter_start_dt date NULL
, fiscal_quarter_end_dt date NULL
, fiscal_quarter_of_year int NULL
, fiscal_quarter_desc_01 varchar(20) NULL
, fiscal_quarter_desc_02 varchar(20) NULL
, fiscal_quarter_desc_03 varchar(50) NULL
, fiscal_quarter_desc_04 varchar(50) NULL
, fiscal_quarter_periods int NULL
, fiscal_quarter_days int NULL
, fiscal_quarter_weekdays int NULL

, fiscal_year_key int NULL
, fiscal_year int NULL
, fiscal_year_start_dt date NULL
, fiscal_year_end_dt date NULL
, fiscal_year_desc_01 varchar(20) NULL
, fiscal_year_periods int NULL
, fiscal_year_quarters int NULL
, fiscal_year_days int NULL
, fiscal_year_weekdays int NULL

, day_index int NULL
, week_index int NULL
, month_index int NULL
, quarter_index int NULL
, year_index int NULL
, fiscal_week_index int NULL
, fiscal_period_index int NULL
, fiscal_quarter_index int NULL
, fiscal_year_index int NULL
, batch_key int NOT NULL
, CONSTRAINT calendar_pk PRIMARY KEY (date_key)
);