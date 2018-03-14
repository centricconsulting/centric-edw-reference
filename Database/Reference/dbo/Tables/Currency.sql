CREATE TABLE [dbo].[Currency]
(
  CurrencyCode varchar(20) NOT NULL
, CurrencyDesc varchar(200) NOT NULL
, CurrencySymbol nvarchar(20) NULL
, CONSTRAINT dbo_Currency_PK PRIMARY KEY (CurrencyCode)
);
