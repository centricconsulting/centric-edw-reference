CREATE TABLE [ver].[state] (

  -- VERSION KEY (named for the table, not grain)
  state_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, state_uid VARCHAR(200) NOT NULL

  -- FOREIGN KEY COLUMNS
, country_uid VARCHAR(200) NOT NULL

  -- ATTRIBUTE COLUMNS
, state_desc varchar(200) NOT NULL
, state_code varchar(100) NOT NULL
, state_country_code VARCHAR(200) NOT NULL

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_state_pk PRIMARY KEY NONCLUSTERED (state_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_state_cx ON ver.[state] (state_uid);
GO

