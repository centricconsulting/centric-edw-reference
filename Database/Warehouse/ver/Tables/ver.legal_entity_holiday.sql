CREATE TABLE [ver].[legal_entity_holiday] (

  -- VERSION KEY (named for the table, not grain)
  legal_entity_holiday_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, legal_entity_uid VARCHAR(200) NOT NULL
, holiday_date DATE NOT NULL

  -- FOREIGN KEY COLUMNS

  -- ATTRIBUTE COLUMNS
, holiday_desc VARCHAR(100) NOT NULL

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_legal_entity_holiday_pk PRIMARY KEY NONCLUSTERED (legal_entity_holiday_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_legal_entity_holiday_cx ON ver.legal_entity_holiday (legal_entity_uid, holiday_date);
GO

