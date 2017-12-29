/*
################################################################################

OBJECT: VIEW dbo.legal_entity_holiday

DESCRIPTION: Exposes the current view of the version legal_entity_holiday table,
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

CREATE VIEW dbo.legal_entity_holiday AS
SELECT 
  -- KEY COLUMNS
  v.legal_entity_holiday_version_key
, vx.legal_entity_holiday_key

  -- GRAIN COLUMNS
, v.legal_entity_uid
, v.holiday_date

  -- FOREIGN KEY COLUMNS

  -- ATTRIBUTE COLUMNS
, v.holiday_desc

  -- SOURCE COLUMNS
, v.source_uid
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
ver.legal_entity_holiday v
INNER JOIN vex.legal_entity_holiday vx ON vx.legal_entity_holiday_version_key = v.legal_entity_holiday_version_key
WHERE
vx.version_latest_ind = 1