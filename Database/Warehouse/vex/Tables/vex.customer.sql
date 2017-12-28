CREATE TABLE [vex].[customer] (

  customer_version_key INT NOT NULL
, customer_key INT NOT NULL

, version_index INT NOT NULL
, version_current_ind BIT NOT NULL
, version_latest_ind BIT NOT NULL

, end_version_dtmx DATETIME2 NOT NULL
, end_version_batch_key INT NOT NULL
, end_source_rev_dtmx DATETIME2 NOT NULL

, CONSTRAINT vex_customer_pk PRIMARY KEY (customer_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_customer_u1 ON vex.customer (customer_version_key) WHERE version_latest_ind = 1;
GO

