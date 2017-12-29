CREATE TABLE [dbo].[CountryForecast]
(
  FiscalYear int NOT NULL
, FiscalPeriodOfYear int NOT NULL
, CountryCode varchar(20) NOT NULL
, ForecastCurrencyCode varchar(20) NOT NULL
, ForecastSales money NOT NULL
, ForecastGrossMargin money NOT NULL
, process_batch_key int NOT NULL
, CONSTRAINT dbo_SalesForecast_PK PRIMARY KEY (FiscalYear, FiscalPeriodOfYear, CountryCode)
)
