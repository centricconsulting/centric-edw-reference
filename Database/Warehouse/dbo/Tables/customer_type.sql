CREATE TABLE dbo.customer_type (
  customer_type_key int NOT NULL

, customer_type_desc varchar(100) NOT NULL
, customer_type_code varchar(20) NOT NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT customer_type_pk PRIMARY KEY (customer_type_key)
);