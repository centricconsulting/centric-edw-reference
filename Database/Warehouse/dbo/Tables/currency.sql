CREATE TABLE dbo.currency (
  currency_key int NOT NULL

, currency_desc varchar(200) NOT NULL
, currency_code varchar(20) NOT NULL
, currency_symbol nvarchar(20) NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT currency_pk PRIMARY KEY (currency_key)
);