CREATE TABLE [dbo].[fiscal_period]
(
  fiscal_year int NOT NULL
, fiscal_period_of_year int NOT NULL
, begin_date date
, end_date date
, display_month_of_year int NOT NULL
, CONSTRAINT fiscal_period_pk PRIMARY KEY (fiscal_year, fiscal_period_of_year)
)
