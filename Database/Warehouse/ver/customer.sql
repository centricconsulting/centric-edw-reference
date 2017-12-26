CREATE TABLE [ver].[customer] (

  customer_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMN(S)
, customer_uid VARCHAR(200) NOT NULL
, version_begin_dtm DATETIME NOT NULL

, customer_desc varchar(100) NOT NULL
, customer_nbr VARCHAR(20) NULL
, customer_type_uid VARCHAR(200) NOT NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_begin_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT ver_customer_pk PRIMARY KEY (customer_uid, version_begin_dtm)
);
GO

CREATE UNIQUE INDEX ver_customer_u1 ON ver.customer (customer_version_key);
GO