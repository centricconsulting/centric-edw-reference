/* ################################################################################

OBJECT: vex.[sales_order_line_status_history_settle_merge]

DESCRIPTION: Performs a merge of all version records related to grain values that have been affected
  on or after the specified batch key.

PARAMETERS:

  @begin_version_batch_key INT = The minimum batch key used to determine with grain records should
    be considered in the settle.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC


################################################################################ */

CREATE PROCEDURE vex.[sales_order_line_status_history_settle_merge] 
  @begin_version_batch_key INT
, @supress_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @supress_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.sales_order_line_status_history vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.sales_order_line_status_history vs
      WHERE vs.sales_order_line_status_history_version_key = vt.sales_order_line_status_history_version_key
    );

  END


  MERGE vex.sales_order_line_status_history WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.sales_order_line_status_history_version_key

    , LEAD(v.sales_order_line_status_history_version_key, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS next_sales_order_line_status_history_version_key

    , MIN(v.sales_order_line_status_history_version_key) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date) AS sales_order_line_status_history_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.sales_order_line_status_history_version_key) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_history_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.sales_order_line_status_history_version_key) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_history_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.sales_order_line_status_history v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.sales_order_line_status_history vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.sales_order_line_uid = v.sales_order_line_uid
      AND vg.status_date = v.status_date

    )

  ) AS vs

  ON vs.sales_order_line_status_history_version_key = vt.sales_order_line_status_history_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_sales_order_line_status_history_version_key, -1) != 
      COALESCE(vt.next_sales_order_line_status_history_version_key, -1) THEN

    UPDATE SET
      next_sales_order_line_status_history_version_key = vs.next_sales_order_line_status_history_version_key
    , sales_order_line_status_history_key = vs.sales_order_line_status_history_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      sales_order_line_status_history_version_key
    , next_sales_order_line_status_history_version_key
    , sales_order_line_status_history_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.sales_order_line_status_history_version_key
    , vs.next_sales_order_line_status_history_version_key
    , vs.sales_order_line_status_history_key
    , vs.version_index
    , vs.version_current_ind
    , vs.version_latest_ind
    , vs.end_version_dtmx
    , vs.end_version_batch_key
    , vs.end_source_rev_dtmx
    )

  ;


END;