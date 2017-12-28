CREATE TABLE [ver].[customer] (

  customer_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, customer_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS
, customer_type_uid VARCHAR(200) NOT NULL

  -- ATTRIBUTE COLUMNS
, customer_desc varchar(100) NOT NULL
, customer_nbr VARCHAR(20) NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- BOILERPLATE: batch key columns
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_customer_pk PRIMARY KEY NONCLUSTERED (customer_version_key)

);
GO

CREATE CLUSTERED INDEX customer_cx ON ver.customer (customer_uid);
GO
