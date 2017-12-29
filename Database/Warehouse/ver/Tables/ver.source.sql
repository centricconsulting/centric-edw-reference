CREATE TABLE [ver].[source] (

  -- VERSION KEY (named for the table, not grain)
  source_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, source_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS

  -- ATTRIBUTE COLUMNS
, [source_name] VARCHAR (50)  NOT NULL
, [source_desc] VARCHAR (100) NULL
, [source_code] VARCHAR(20) NOT NULL

  -- SOURCE COLUMNS (Passive)
  -- MOVED source_uid to GRAIN COLUMNS for this table only
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_source_pk PRIMARY KEY NONCLUSTERED (source_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_source_cx ON ver.source (source_uid);
GO

