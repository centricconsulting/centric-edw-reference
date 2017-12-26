CREATE TABLE [dbo].[sales_order]
(
  -- GRAIN COLUMN(S)
  sales_order_key int IDENTITY(1000,1) NOT NULL


  -- GRAIN COLUMN(S)
, sales_order_uid VARCHAR(200) NOT NULL

  -- KEY ATTRIBUTES
, customer_uid VARCHAR(200) NOT NULL
, sales_order_date_uid VARCHAR(200) NOT NULL

  -- OTHER ATTRIBUTES
, sales_order_dt date NOT NULL
, sales_order_nbr varchar(20) NOT NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT dbo_sales_order_pk PRIMARY KEY CLUSTERED (sales_order_uid)
);