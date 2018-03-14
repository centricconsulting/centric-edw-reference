CREATE TABLE [dbo].[reference]
(
  reference_key INT IDENTITY(1,1) NOT NULL
, current_year INT NOT NULL
, [current_date] DATE NOT NULL
, current_date_key INT NOT NULL
, current_date_desc VARCHAR(20) NOT NULL
, current_month_key INT NOT NULL
, current_month_desc VARCHAR(20) NOT NULL
, closed_month_key INT NOT NULL
, closed_month_desc VARCHAR(20) NOT NULL
, mart_refresh_timestamp DATETIME NOT NULL
, wwi_refresh_timestamp DATETIME NOT NULL
, CONSTRAINT dbo_reference_pk PRIMARY KEY (reference_key)
, CONSTRAINT dbo_reference_ch1 CHECK (reference_key = 1)
);
