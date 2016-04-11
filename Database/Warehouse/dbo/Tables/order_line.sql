CREATE TABLE [dbo].[order_line]
(
  -- GRAIN COLUMN(S)
  order_line_key int NOT NULL

  -- KEY ATTRIBUTES
, order_key int NOT NULL
, order_line_index int NOT NULL
, product_key int NOT NULL
, current_order_line_status_key int NOT NULL

  -- OTHER ATTRIBUTES
, sale_unit_qty decimal(20,12)
, sale_amt money
, tax_amt money
, freight_amt money
, standard_cost_amt money

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT dbo_order_line_pk PRIMARY KEY (order_line_key)
);