CREATE TABLE [vex].[customer_type] (

  -- KEY COLUMNS
  customer_type_version_key INT NOT NULL
, customer_type_key INT NOT NULL

  -- GRAIN COLUMNS
, customer_type_uid VARCHAR(200) NOT NULL

  -- VERSION ATTRIBUTES
, version_index INT NOT NULL
, version_current_ind BIT NOT NULL
, version_latest_ind BIT NOT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_customer_type_pk PRIMARY KEY (customer_type_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_customer_type_u1 ON vex.customer_type (customer_type_version_key) WHERE version_latest_ind = 1;
GO

