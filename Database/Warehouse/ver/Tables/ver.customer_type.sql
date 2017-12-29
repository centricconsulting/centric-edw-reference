CREATE TABLE [ver].[customer_type] (

  -- VERSION KEY (named for the table, not grain)
  customer_type_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, customer_type_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS

  -- ATTRIBUTE COLUMNS
, customer_type_desc varchar(100) NOT NULL
, customer_type_code varchar(20) NOT NULL

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_customer_type_pk PRIMARY KEY NONCLUSTERED (customer_type_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_customer_type_cx ON ver.customer_type (customer_type_uid);
GO

