/* ################################################################################

OBJECT: vex.generic_settle.

DESCRIPTION: Merges (insert, update, delete) corresponding VEX table using settlement logic.  Records
  considered are those whose grain is associated with records where the VERSION_BATCH_KEY exceeds
  the parameterized batch key value.

PARAMETERS:

  @table_name VARCHAR(200) = Unqualified table name (without schema) in the VER schema.  
    NOTE: Assumes that the CLUSTERED index of this table contains only grain columns.

  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE vex.generic_settle
  @table_name VARCHAR(200)
AS BEGIN

  SET NOCOUNT ON;
  DECLARE @sql NVARCHAR(max);

  SET @sql = 'TRUNCATE TABLE vex.' + @table_name;

  -- PRINT @sql;
  EXEC sp_executesql @sql;

  DECLARE @window_grain_list VARCHAR(1000) = 
    vex.build_grain_phrase(@table_name, 'v.{c}', DEFAULT);

  SET @sql=N'INSERT INTO vex.' + @table_name + ' (
    ' + @table_name + '_version_key
  , next_' + @table_name + '_version_key
  , ' + @table_name + '_key
  , version_index
  , version_current_ind
  , version_latest_ind
  , end_version_dtmx
  , end_version_batch_key
  , end_source_rev_dtmx
  )
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
  ver.' + @table_name + ' v'

  -- PRINT @sql;
  EXEC sp_executesql @sql;

END