CREATE TABLE [ver].[sales_order_line] (

  -- VERSION KEY (named for the table, not grain)
  sales_order_line_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, sales_order_line_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS
, sales_order_uid VARCHAR(200) NOT NULL
, item_uid VARCHAR(200) NOT NULL
, product_uid VARCHAR(200) NOT NULL
, current_sales_order_line_status_uid VARCHAR(200) NOT NULL

  -- ATTRIBUTE COLUMNS
, sales_order_line_desc VARCHAR(200) NULL
, sales_order_line_index INT NULL
, item_unit_qty DECIMAL(20,12) NULL
, item_sale_amt MONEY NULL
, tax_amt MONEY NULL
, freight_amt MONEY NULL
, standard_cost_amt MONEY NULL

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_sales_order_line_pk PRIMARY KEY NONCLUSTERED (sales_order_line_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_sales_order_line_cx ON ver.sales_order_line (sales_order_line_uid);
GO

