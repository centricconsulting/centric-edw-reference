/* ################################################################################

OBJECT: vex.[customer_settlement].

DESCRIPTION: Truncates corresponding VEX table and reloads it using settlement logic.

PARAMETERS: None.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE [vex].[customer_settlement] AS
BEGIN

TRUNCATE TABLE vex.[customer];

INSERT INTO vex.customer (
  customer_version_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT
  c.customer_version_key

, ROW_NUMBER() OVER (PARTITION BY customer_uid
    ORDER BY c.version_dtm, c.customer_version_key) AS version_index

  -- XOR "^" inverts the deleted indicator
, LAST_VALUE(c.source_delete_ind) OVER (PARTITION BY customer_uid
    ORDER BY c.version_dtm, c.customer_version_key) ^ 1 AS version_current_ind

, CASE WHEN c.customer_version_key = LAST_VALUE(c.customer_version_key) OVER (PARTITION BY customer_uid
    ORDER BY c.version_dtm, c.customer_version_key) THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(c.version_dtm) OVER (PARTITION BY customer_uid
    ORDER BY c.version_dtm, c.customer_version_key) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(c.version_batch_key) OVER (PARTITION BY customer_uid
    ORDER BY c.version_dtm, c.customer_version_key) - 1 AS end_version_batch_key

, LEAD(c.source_rev_dtm) OVER (PARTITION BY customer_uid
    ORDER BY c.version_dtm, c.customer_version_key) AS end_source_rev_dtmx
FROM
ver.customer c

END;
