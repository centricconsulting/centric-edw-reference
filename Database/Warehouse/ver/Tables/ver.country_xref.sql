CREATE TABLE [ver].[country_xref] (

  -- VERSION KEY (named for the table, not grain)
  country_xref_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, country_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS
, master_country_uid VARCHAR(200) NOT NULL

  -- ATTRIBUTE COLUMNS

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_country_xref_pk PRIMARY KEY NONCLUSTERED (country_xref_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_country_xref_cx ON ver.[country_xref] (country_uid);
GO

