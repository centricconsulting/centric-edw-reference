CREATE TABLE [vex].[state] (

  -- KEY COLUMNS
  state_version_key INT NOT NULL
, state_key INT NOT NULL

  -- GRAIN COLUMNS
, state_uid VARCHAR(200) NOT NULL

  -- VERSION ATTRIBUTES
, version_index INT NOT NULL
, version_current_ind BIT NOT NULL
, version_latest_ind BIT NOT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_state_pk PRIMARY KEY (state_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_state_u1 ON vex.state (state_version_key) WHERE version_latest_ind = 1;
GO

