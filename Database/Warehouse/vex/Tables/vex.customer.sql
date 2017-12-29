CREATE TABLE [vex].[customer] (

  customer_version_key INT NOT NULL
, customer_key INT NOT NULL

  -- GRAIN COLUMNS
, customer_uid VARCHAR(200) NOT NULL

  -- VERSION ATTRIBUTES
, version_index INT NOT NULL
, version_current_ind BIT NOT NULL
, version_latest_ind BIT NOT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_customer_pk PRIMARY KEY (customer_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_customer_u1 ON vex.customer (customer_version_key) WHERE version_latest_ind = 1;
GO

