CREATE TABLE [dbo].[sales_order_line]
(
  -- GRAIN COLUMN(S)
  sales_order_line_key int IDENTITY(1000,1) NOT NULL


  -- GRAIN COLUMN(S)
, sales_order_line_uid VARCHAR(200) NOT NULL

  -- KEY ATTRIBUTES
, sales_order_uid VARCHAR(200) NOT NULL
, sales_order_line_index int NOT NULL
, product_uid VARCHAR(200) NOT NULL
, current_sales_order_line_status_uid VARCHAR(200) NOT NULL

  -- OTHER ATTRIBUTES
, sale_unit_qty decimal(20,12)
, sale_amt money
, tax_amt money
, freight_amt money
, standard_cost_amt money

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT dbo_sales_order_line_pk PRIMARY KEY (sales_order_line_uid)
);