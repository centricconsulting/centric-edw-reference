CREATE TABLE [vex].[customer] (

  customer_version_key INT NOT NULL

, customer_uid VARCHAR(200) NOT NULL
, version_index int NOT NULL

, version_current_ind bit NOT NULL
, version_latest_ind bit NOT NULL

, version_end_dtmx DATETIME NOT NULL
, source_revision_end_dtmx DATETIME NOT NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT vex_customer_pk PRIMARY KEY (customer_uid, version_index)
)
;
GO

CREATE UNIQUE INDEX vex_customer_cx ON vex.customer (customer_version_key) INCLUDE (version_latest_ind);
GO

