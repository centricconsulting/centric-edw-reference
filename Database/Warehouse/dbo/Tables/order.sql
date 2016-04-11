CREATE TABLE [dbo].[order]
(
  -- GRAIN COLUMN(S)
  order_key int NOT NULL

  -- KEY ATTRIBUTES
, customer_key int NOT NULL
, order_date_key int NOT NULL

  -- OTHER ATTRIBUTES
, order_dt date NOT NULL
, order_nbr varchar(20) NOT NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT dbo_order_pk PRIMARY KEY (order_key)
);