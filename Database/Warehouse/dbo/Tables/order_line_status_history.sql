CREATE TABLE [dbo].[order_line_status_history]
(
  -- GRAIN COLUMN(S)
  order_line_key int NOT NULL
, status_date_key int NOT NULL

  -- KEY ATTRIBUTES
, order_line_status_key int NOT NULL

  -- OTHER ATTRIBUTES
, status_dt date NOT NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT [dbo_order_line_status_history] PRIMARY KEY (order_line_key, status_date_key)
);