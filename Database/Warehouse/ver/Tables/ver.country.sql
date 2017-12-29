CREATE TABLE [ver].[country] (

  -- VERSION KEY (named for the table, not grain)
  country_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, country_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS

  -- ATTRIBUTE COLUMNS
, country_code varchar(20) NOT NULL
, country_desc varchar(200) NOT NULL

, world_subregion_desc varchar(200) NOT NULL
, world_region_desc varchar(200) NOT NULL

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_country_pk PRIMARY KEY NONCLUSTERED (country_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_country_cx ON ver.[country] (country_uid);
GO

