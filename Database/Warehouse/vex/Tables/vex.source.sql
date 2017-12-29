CREATE TABLE [vex].[source] (

  -- KEY COLUMNS
  source_version_key INT NOT NULL
, source_key INT NOT NULL

  -- GRAIN COLUMNS
, source_uid VARCHAR(200) NOT NULL

  -- VERSION ATTRIBUTES
, version_index INT NOT NULL
, version_current_ind BIT NOT NULL
, version_latest_ind BIT NOT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_source_pk PRIMARY KEY (source_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_source_u1 ON vex.source (source_version_key) WHERE version_latest_ind = 1;
GO

