/*
################################################################################

OBJECT: VIEW dbo.source

DESCRIPTION: Exposes the current view of the version source table,
  either latest or current version records.
  
RETURN DATASET:

  - Columns are identical to the corresponding version table.
  - The version key is retained for reference purposes.
  - WITH SCHEMABINDING enables the unique index to be added to the view
  - Assumes that grain column in the version table is unique based on version latest/current
  - The filter "version_latest_ind = 1" is used for domain tables, whereas "version_current_ind = 1" is used for transaction tables.

NOTES:

  Content views are provided as a way of exposing the current state records
  of Version tables.  This makes it possible to query the dbo schema consistently
  without special logic being applied by the analyst.

HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-28  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################
*/

CREATE VIEW dbo.source AS
SELECT 
  -- KEY COLUMNS
  v.source_version_key
, vx.source_key

  -- GRAIN COLUMNS
, v.source_uid

  -- FOREIGN KEY COLUMNS

  -- ATTRIBUTES
, v.[source_name]
, v.[source_desc]
, v.[source_code]

  -- SOURCE COLUMNS
  -- MOVED source_uid to GRAIN COLUMNS for this table only
, v.source_rev_dtm AS begin_source_rev_dtm
, vx.end_source_rev_dtmx
, v.source_rev_actor

  -- VERSION COLUMNS
, vx.version_index
, v.version_dtm AS begin_version_dtm
, vx.end_version_dtmx
, vx.version_latest_ind
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key AS begin_version_batch_key
, vx.end_version_batch_key

FROM
ver.source v
INNER JOIN vex.source vx ON vx.source_version_key = v.source_version_key
WHERE
vx.version_latest_ind = 1