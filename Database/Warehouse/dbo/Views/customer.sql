/*
################################################################################

OBJECT: VIEW dbo.customer

DESCRIPTION: Exposes the current view of the version customer table.
  
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
  2016-03-15  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################
*/

CREATE VIEW dbo.customer AS
SELECT 
  -- latest version key is used as the key
  c.customer_version_key AS customer_key
, c.customer_uid
, c.customer_desc
, c.customer_nbr

, c.source_uid
, c.source_rev_dtm AS begin_source_rev_dtm
, cx.end_source_rev_dtmx
, c.source_rev_actor

, c.version_batch_key AS begin_version_batch_key
, cx.end_version_batch_key

, c.version_dtm AS begin_version_dtm
, cx.end_version_dtmx

FROM
ver.customer c
INNER JOIN vex.customer cx ON cx.customer_version_key = c.customer_version_key
WHERE
cx.version_latest_ind = 1
GO
