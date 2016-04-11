CREATE TABLE dbo.order_line_status (
  order_line_status_key int NOT NULL

, order_line_status_desc varchar(100) NOT NULL
, order_line_status_code varchar(20) NOT NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT dbo_order_line_status_pk PRIMARY KEY (order_line_status_key)
);