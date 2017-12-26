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

CREATE VIEW dbo.customer WITH SCHEMABINDING AS
SELECT 
  c.customer_version_key AS customer_key
, c.customer_uid
, c.customer_desc
, c.customer_nbr

, c.source_uid
, c.source_revision_begin_dtm AS source_revision_dtm
, c.source_revision_actor

, c.provision_batch_key
, c.revision_batch_key

FROM
ver.customer c
LEFT JOIN vex.customer cx ON cx.customer_version_key = c.customer_version_key
WHERE
cx.version_latest_ind = 1
GO
