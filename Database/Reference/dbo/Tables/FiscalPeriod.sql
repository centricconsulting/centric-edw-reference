CREATE TABLE [dbo].FiscalPeriod
(
  FiscalYear int NOT NULL
, FiscalPeriodOfYear int NOT NULL
, BeginDate date NOT NULL
, EndDate date NULL
, FiscalPeriodClosedFlag CHAR(1) NOT NULL
, DisplayMonthOfYear int NOT NULL

, process_batch_key int NOT NULL
, CONSTRAINT dbo_FiscalPeriod_PK PRIMARY KEY (FiscalYear, FiscalPeriodOfYear)
)
