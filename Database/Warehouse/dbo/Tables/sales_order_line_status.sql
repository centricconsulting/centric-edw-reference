CREATE TABLE dbo.sale_order_line_status (
  sale_order_line_status_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMN(S)
, sale_order_line_status_uid VARCHAR(200) NOT NULL

, sale_order_line_status_desc varchar(100) NOT NULL
, sale_order_line_status_code varchar(20) NOT NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT dbo_sale_order_line_status_pk PRIMARY KEY (sale_order_line_status_uid)
);