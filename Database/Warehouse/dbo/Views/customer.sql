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
  c.customer_key
, c.customer_type_key
, c.geography_key
, c.customer_name
, c.primary_contact_name
, c.primary_contact_phone_nbr
, c.address_line1
, c.address_line2
, c.city
, c.state_desc
, c.country_desc
, c.postal_code
, c.address_lattitude
, c.address_longitude

, c.source_key
, c.source_revision_actor

-- present the standard content table column, source_revision_dtm
, c.source_revision_begin_dtm AS source_revision_dtm

-- retain version key for reference purposes
, c.customer_version_key

, c.init_process_batch_key
, c.process_batch_key
FROM
ver.customer c
WHERE
c.version_latest_ind = 1
GO

-- unique index on the grain column(s) from the version table.
CREATE UNIQUE CLUSTERED INDEX dbo_customer_gx ON dbo.customer (customer_key);
GO
