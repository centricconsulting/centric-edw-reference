CREATE TABLE dbo.customer_type (
  customer_type_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMN(S)
 ,customer_type_uid VARCHAR(200) NOT NULL

, customer_type_desc varchar(100) NOT NULL
, customer_type_code varchar(20) NOT NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT dbo_customer_type_pk PRIMARY KEY (customer_type_uid)
);