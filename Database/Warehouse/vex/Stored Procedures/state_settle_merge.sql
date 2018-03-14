/* ################################################################################

OBJECT: vex.[state_settle_merge]

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

CREATE PROCEDURE vex.[state_settle_merge] 
  @begin_version_batch_key INT
, @supress_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @supress_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.state vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.state vs
      WHERE vs.state_version_key = vt.state_version_key
    );

  END


  MERGE vex.state WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.state_version_key

    , LEAD(v.state_version_key, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS next_state_version_key

    , MIN(v.state_version_key) OVER (
        PARTITION BY v.state_uid) AS state_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.state_version_key) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.state_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.state_version_key) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.state_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.state v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.state vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.state_uid = v.state_uid

    )

  ) AS vs

  ON vs.state_version_key = vt.state_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_state_version_key, -1) != 
      COALESCE(vt.next_state_version_key, -1) THEN

    UPDATE SET
      next_state_version_key = vs.next_state_version_key
    , state_key = vs.state_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      state_version_key
    , next_state_version_key
    , state_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.state_version_key
    , vs.next_state_version_key
    , vs.state_key
    , vs.version_index
    , vs.version_current_ind
    , vs.version_latest_ind
    , vs.end_version_dtmx
    , vs.end_version_batch_key
    , vs.end_source_rev_dtmx
    )

  ;


END;