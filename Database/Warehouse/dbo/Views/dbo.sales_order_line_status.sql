/* ################################################################################

OBJECT: VIEW dbo.[sales_order_line_status]

DESCRIPTION: Exposes the current view of the version sales_order_line_status table,
  either latest or current version records.
  
RETURN DATASET:

  - Columns are identical to the corresponding version table.
  - The version key is retained for reference purposes.
  - Assumes that grain column in the version table is unique based on version latest/current
  - The filter "version_latest_ind = 1" is used for domain tables, whereas "version_current_ind = 1" is used for transaction tables.
  - Because this only contains latest records, the end dates have been supressed; they are always null.

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

CREATE VIEW dbo.[sales_order_line_status] AS
SELECT 

  -- KEY COLUMNS
  vx.sales_order_line_status_key

  -- GRAIN COLUMNS
 , v.sales_order_line_status_uid

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.sales_order_line_status_desc
 , v.sales_order_line_status_code

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.sales_order_line_status_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.sales_order_line_status v
INNER JOIN vex.sales_order_line_status vx ON
  vx.sales_order_line_status_version_key = v.sales_order_line_status_version_key
WHERE
vx.version_latest_ind = 1