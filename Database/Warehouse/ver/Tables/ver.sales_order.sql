CREATE TABLE [ver].[sales_order] (

  -- VERSION KEY (named for the table, not grain)
  sales_order_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, sales_order_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS
, customer_uid VARCHAR(200) NOT NULL
, sales_order_dt DATE NOT NULL
, legal_entity_uid VARCHAR(200) NOT NULL

  -- ATTRIBUTE COLUMNS
, sales_order_nbr VARCHAR(20) NOT NULL

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_sales_order_pk PRIMARY KEY NONCLUSTERED (sales_order_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_sales_order_cx ON ver.sales_order (sales_order_uid);
GO

