/* ################################################################################

OBJECT: vex.generic_table_settlement.

DESCRIPTION: Truncates corresponding VEX table and reloads it using settlement logic.

PARAMETERS:

  @table_name VARCHAR(200) = Unqualified table name (without schema) in the VER schema.  
    NOTE: Assumes that the CLUSTERED index of this table contains only grain columns.

  @begin_version_batch_key INT = The minimum batch key used to determine with grain records should
    be considered in the settle.

  @supress_cleanup_ind BIT (DEFAULT 0) = Signals the procedure to not execute a cleanup of the
    settlement table.  Cleanup involves removing any records without a corresponding key record
    in the version table.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE vex.generic_settle_merge  
  @table_name VARCHAR(200)
, @begin_version_batch_key INT
, @supress_cleanup_ind bit = 0
AS BEGIN

  SET NOCOUNT ON;
  DECLARE @sql NVARCHAR(max);

  -- cleanup orphaned VEX records
  IF @supress_cleanup_ind = 0
  BEGIN

    SET @sql = N'DELETE vt FROM
vex.' + @table_name + ' vt
WHERE
NOT EXISTS (
  SELECT 1 FROM ver.' + @table_name + ' vs
  WHERE vs.' + @table_name + '_version_key = vt.' + @table_name + '_version_key)';
    
    -- PRINT @sql
    EXEC sp_executesql @sql;

  END

  DECLARE 
    @window_grain_list VARCHAR(1000)
  , @compare_grain_list VARCHAR(1000);

  SET @window_grain_list = vex.build_grain_phrase(@table_name, 'v.{c}', DEFAULT);

  SET @compare_grain_list = vex.build_grain_phrase(@table_name, 'vg.{c} = v.{c}', 'AND');

  SET @sql=N'MERGE vex.' + @table_name + ' WITH (HOLDLOCK) AS vt

USING (
  
  SELECT

    v.' + @table_name + '_version_key

  , LEAD(v.' + @table_name + '_version_key, 1) OVER (
      PARTITION BY ' + @window_grain_list + '
      ORDER BY v.' + @table_name + '_version_key ASC) AS next_' + @table_name + '_version_key

  , MIN(v.' + @table_name + '_version_key) OVER (
      PARTITION BY ' + @window_grain_list + ') AS ' + @table_name + '_key

  , ROW_NUMBER() OVER (
      PARTITION BY ' + @window_grain_list + '
      ORDER BY v.' + @table_name + '_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.' + @table_name + '_version_key) OVER (
      PARTITION BY ' + @window_grain_list + '
      ORDER BY v.' + @table_name + '_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.' + @table_name + '_version_key 
      THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

  , CASE
    WHEN LAST_VALUE(v.' + @table_name + '_version_key) OVER (
      PARTITION BY ' + @window_grain_list + '
      ORDER BY v.' + @table_name + '_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.' + @table_name + '_version_key THEN 1
    ELSE 0 END AS version_latest_ind

  , LEAD(v.version_dtm, 1) OVER (
      PARTITION BY ' + @window_grain_list + '
      ORDER BY v.' + @table_name + '_version_key ASC) AS end_version_dtmx

    -- Back the LEAD batch key off by 1
  , LEAD(v.version_batch_key, 1) OVER (
      PARTITION BY ' + @window_grain_list + '
      ORDER BY v.' + @table_name + '_version_key ASC) - 1 AS end_version_batch_key

  , LEAD(v.source_rev_dtm, 1) OVER (
      PARTITION BY ' + @window_grain_list + '
      ORDER BY v.' + @table_name + '_version_key ASC) AS end_source_rev_dtmx

  FROM
  ver.' + @table_name + ' v
  WHERE
  EXISTS (

	  SELECT 1 FROM ver.' + @table_name + ' vg
	  WHERE vg.version_batch_key >= ' + CAST(@begin_version_batch_key AS VARCHAR(20)) + ' AND
   ' + @compare_grain_list + '
  )

) AS vs

ON vs.' + @table_name + '_version_key = vt.' + @table_name + '_version_key 

WHEN MATCHED
  AND COALESCE(vs.next_' + @table_name + '_version_key, -1) != 
    COALESCE(vt.next_' + @table_name + '_version_key, -1) THEN

  UPDATE SET
    next_' + @table_name + '_version_key = vs.next_' + @table_name + '_version_key
  , ' + @table_name + '_key = vs.' + @table_name + '_key
  , version_index = vs.version_index
  , version_current_ind = vs.version_current_ind
  , version_latest_ind = vs.version_latest_ind
  , end_version_dtmx = vs.end_version_dtmx
  , end_version_batch_key = vs.end_version_batch_key
  , end_source_rev_dtmx = vs.end_source_rev_dtmx

WHEN NOT MATCHED BY TARGET THEN

  INSERT (
    ' + @table_name + '_version_key
  , next_' + @table_name + '_version_key
  , ' + @table_name + '_key
  , version_index
  , version_current_ind
  , version_latest_ind
  , end_version_dtmx
  , end_version_batch_key
  , end_source_rev_dtmx
  )  VALUES (
    vs.' + @table_name + '_version_key
  , vs.next_' + @table_name + '_version_key
  , vs.' + @table_name + '_key
  , vs.version_index
  , vs.version_current_ind
  , vs.version_latest_ind
  , vs.end_version_dtmx
  , vs.end_version_batch_key
  , vs.end_source_rev_dtmx
  );'

  -- PRINT @sql;
  EXEC sp_executesql @sql;

END