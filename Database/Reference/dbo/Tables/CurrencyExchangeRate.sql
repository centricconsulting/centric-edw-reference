CREATE TABLE [dbo].[CurrencyExchangeRate]
(
  BaseCurrencyCode VARCHAR(20) NOT NULL
, TargetCurrencyCode VARCHAR(20) NOT NULL
, BeginDate date NOT NULL
, EndDate date NULL
, ExchangeRate DECIMAL(20,12) NOT NULL
, CONSTRAINT dbo_CurrencyExchangeRate_PK PRIMARY KEY (BaseCurrencyCode, TargetCurrencyCode, BeginDate)
)
