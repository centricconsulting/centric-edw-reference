CREATE TABLE [dbo].FiscalPeriod
(
  FiscalYear int NOT NULL
, FiscalPeriodOfYear int NOT NULL
, BeginDate date NOT NULL
, EndDate date NULL
, DisplayMonthOfYear int NOT NULL
, CONSTRAINT FiscalPeriod_PK PRIMARY KEY (FiscalYear, FiscalPeriodOfYear)
)
