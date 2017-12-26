CREATE TABLE dbo.currency (

  currency_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMN(S)
, currency_uid VARCHAR(200) NOT NULL

, currency_desc varchar(200) NOT NULL
, currency_code varchar(20) NOT NULL
, currency_symbol nvarchar(20) NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT dbo_currency_pk PRIMARY KEY CLUSTERED (currency_uid)
);