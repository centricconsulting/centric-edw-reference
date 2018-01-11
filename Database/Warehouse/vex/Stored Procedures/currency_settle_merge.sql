/* ################################################################################

OBJECT: vex.[currency_settle_merge]

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

CREATE PROCEDURE vex.[currency_settle_merge] 
  @begin_version_batch_key INT
AS
BEGIN

  SET NOCOUNT ON;

  MERGE vex.currency AS vt

  USING (
  
    SELECT

      v.currency_version_key

    , LEAD(v.currency_version_key, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS next_currency_version_key

    , MIN(v.currency_version_key) OVER (
        PARTITION BY v.currency_uid) AS currency_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , LAST_VALUE(v.source_delete_ind) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) ^ 1 AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.currency_version_key) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) = v.currency_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.currency v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.currency vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key
	    AND 
      vg.currency_uid = v.currency_uid

    )

  ) AS vs

  ON vs.currency_version_key = vt.currency_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_currency_version_key, -1) != 
      COALESCE(vt.next_currency_version_key, -1) THEN

    UPDATE SET
      next_currency_version_key = vs.next_currency_version_key
    , currency_key = vs.currency_key
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
      currency_version_key
    , next_currency_version_key
    , currency_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.currency_version_key
    , vs.next_currency_version_key
    , vs.currency_key
    , vs.version_index
    , vs.version_current_ind
    , vs.version_latest_ind
    , vs.end_version_dtmx
    , vs.end_version_batch_key
    , vs.end_source_rev_dtmx
    )

  ;


END;