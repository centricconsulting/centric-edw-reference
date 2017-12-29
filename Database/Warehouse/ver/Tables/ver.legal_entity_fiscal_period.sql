CREATE TABLE [ver].[legal_entity_fiscal_period] (

  -- VERSION KEY (named for the table, not grain)
  legal_entity_fiscal_period_version_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMNS
, legal_entity_uid VARCHAR(200)
, fiscal_year INT NOT NULL
, fiscal_period_of_year INT NOT NULL

  -- FOREIGN KEY COLUMNS

  -- ATTRIBUTE COLUMNS
, fiscal_period_begin_dt DATE NOT NULL
, fiscal_period_end_dt DATE NULL
  -- Display Month is the nominal calendar month used for display purposes
, display_month_of_year INT NOT NULL

  -- SOURCE COLUMNS (Passive)
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS (Passive)
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_legal_entity_fiscal_period_pk
    PRIMARY KEY NONCLUSTERED (legal_entity_fiscal_period_version_key)

);
GO

-- NOTE: clustered inded on the Grain Columns is important for
--   later joins in the Warehouse queries
CREATE CLUSTERED INDEX ver_legal_entity_fiscal_period_cx
 ON ver.[legal_entity_fiscal_period] (legal_entity_uid, fiscal_year, fiscal_period_of_year);
GO

