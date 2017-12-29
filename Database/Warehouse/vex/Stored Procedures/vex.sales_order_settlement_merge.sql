   /* ################################################################################

OBJECT: vex.sales_order_settlement_merge.

DESCRIPTION: Truncates corresponding VEX table and reloads it using settlement logic.

PARAMETERS:

  @begin_version_batch_key INT = The minimum batch key used to determine with grain records should
    be considered in the settlement.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE vex.sales_order_settlement_merge
  @begin_version_batch_key INT
AS
BEGIN

  SET NOCOUNT ON

  MERGE vex.sales_order AS vt

  USING (
  
    SELECT
	    v.sales_order_version_key

	    -- THe first version key for the grain becomes the grain key
    , MIN(v.sales_order_version_key) OVER (PARTITION BY v.sales_order_uid) AS sales_order_key

	    -- Grain columns
    , v.sales_order_uid

    , ROW_NUMBER() 
	    OVER (PARTITION BY v.sales_order_uid
	    ORDER BY v.version_dtm, v.sales_order_version_key) AS version_index

	    -- XOR "^" inverts the deleted indicator
    , LAST_VALUE(v.source_delete_ind) 
	    OVER (PARTITION BY v.sales_order_uid
	    ORDER BY v.version_dtm, v.sales_order_version_key) ^ 1 AS version_current_ind

    , CASE WHEN v.sales_order_version_key = LAST_VALUE(v.sales_order_version_key) 
	    OVER (PARTITION BY v.sales_order_uid
	    ORDER BY v.version_dtm, v.sales_order_version_key) THEN 1
	    ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) 
	    OVER (PARTITION BY v.sales_order_uid
	    ORDER BY v.version_dtm, v.sales_order_version_key) AS end_version_dtmx

	    -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) 
	    OVER (PARTITION BY v.sales_order_uid
	    ORDER BY v.version_dtm, v.sales_order_version_key) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) 
	    OVER (PARTITION BY v.sales_order_uid
	    ORDER BY v.version_dtm, v.sales_order_version_key) AS end_source_rev_dtmx

    FROM
    ver.sales_order v
    WHERE
    EXISTS (
	    SELECT vg.sales_order_uid FROM ver.sales_order vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key
	    AND vg.sales_order_uid = v.sales_order_uid
    )

  ) AS vs

  ON vs.sales_order_version_key = vt.sales_order_version_key 

  WHEN MATCHED
    AND ISNULL(vs.end_version_dtmx,'0001-01-01') 
      != ISNULL(vt.end_version_dtmx, '0001-01-01') THEN

    UPDATE SET
      sales_order_key = vs.sales_order_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx


  WHEN NOT MATCHED BY SOURCE THEN
    
    DELETE

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      sales_order_version_key
    , sales_order_key
    , sales_order_uid
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.sales_order_version_key
    , vs.sales_order_key
    , vs.sales_order_uid
    , vs.version_index
    , vs.version_current_ind
    , vs.version_latest_ind
    , vs.end_version_dtmx
    , vs.end_version_batch_key
    , vs.end_source_rev_dtmx
    )

  ;

END;