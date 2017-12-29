/* ################################################################################

OBJECT: vex.generic_table_settlement.

DESCRIPTION: Merges (insert, update, delete) corresponding VEX table using settlement logic.  Records
  considered are those whose grain is associated with records where the VERSION_BATCH_KEY exceeds
  the parameterized batch key value.

PARAMETERS:

  @version_table_name VARCHAR(200) = Unqualified table name (without schema) in the VER schema.  
    NOTE: Assumes that the CLUSTERED index of this table contains only grain columns.

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

CREATE PROCEDURE vex.generic_table_settlement_merge
  @version_table_name VARCHAR(100)
, @begin_version_batch_key INT
AS
BEGIN

  --SET NOCOUNT ON

  -- Retrieve the grain column list for the table
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  DECLARE @version_grain_list VARCHAR(2000);
  SET @version_grain_list = vex.generate_version_grain_list(@version_table_name);

  -- Generate phrases used in sql
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  DECLARE @x1_grain_list VARCHAR(2000);
  DECLARE @x2_grain_list VARCHAR(2000);
  DECLARE @x2c_grain_list VARCHAR(2000);
  DECLARE @x3_grain_list VARCHAR(2000);
  
  SET @x1_grain_list = vex.generate_phrase(@version_grain_list, ',', 'v.{e}', ',');
  SET @x2_grain_list = vex.generate_phrase(@version_grain_list, ',', 'vb.{e}', ',');
  SET @x2c_grain_list = vex.generate_phrase(@version_grain_list, ',','vb.{e} = v.{e}', ' AND ');
  SET @x3_grain_list = vex.generate_phrase(@version_grain_list, ',', 'vs.{e}', ',');

  -- Merge the change data set
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  DECLARE @sql NVARCHAR(4000);

  SET @sql = 
N'MERGE vex.' + @version_table_name + ' AS vt

USING (
  
  SELECT
	  v.' + @version_table_name + '_version_key

	  -- The first version key for the grain becomes the grain key
  , MIN(v.' + @version_table_name + '_version_key) 
    OVER (PARTITION BY ' + @x1_grain_list + ') AS ' + @version_table_name + '_key

	  -- Grain columns
  , ' + @x1_grain_list + '

  , ROW_NUMBER() 
	  OVER (PARTITION BY ' + @x1_grain_list + '
	  ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) AS version_index

	  -- XOR "^" inverts the deleted indicator
  , LAST_VALUE(v.source_delete_ind) 
	  OVER (PARTITION BY ' + @x1_grain_list + '
	  ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) ^ 1 AS version_current_ind

  , CASE WHEN v.' + @version_table_name + '_version_key = LAST_VALUE(v.' + @version_table_name + '_version_key) 
	  OVER (PARTITION BY ' + @x1_grain_list + '
	  ORDER BY v.version_dtm, v.' + @version_table_name+ '_version_key) THEN 1
	  ELSE 0 END AS version_latest_ind

  , LEAD(v.version_dtm, 1) 
	  OVER (PARTITION BY ' + @x1_grain_list + '
	  ORDER BY v.version_dtm, v.' + @version_table_name+ '_version_key) AS end_version_dtmx

	  -- Back the LEAD batch key off by 1
  , LEAD(v.version_batch_key, 1) 
	  OVER (PARTITION BY ' + @x1_grain_list + '
	  ORDER BY v.version_dtm, v.' + @version_table_name+ '_version_key) - 1 AS end_version_batch_key

  , LEAD(v.source_rev_dtm, 1) 
	  OVER (PARTITION BY ' + @x1_grain_list + '
	  ORDER BY v.version_dtm, v.' + @version_table_name+ '_version_key) AS end_source_rev_dtmx

  FROM
  ver.' + @version_table_name+ ' v
  WHERE
  EXISTS (
	  SELECT ' + @x2_grain_list + ' FROM ver.' + @version_table_name + ' vb
	  WHERE vb.version_batch_key >= ' + CAST(@begin_version_batch_key AS VARCHAR(20)) + '
	  AND ' + @x2c_grain_list + '
  )

) AS vs

ON vs.' + @version_table_name + '_version_key = vt.' + @version_table_name + '_version_key 

WHEN MATCHED
  AND ISNULL(vs.end_version_dtmx,''0001-01-01'') 
    != ISNULL(vt.end_version_dtmx, ''0001-01-01'') THEN

  UPDATE SET
    ' + @version_table_name + '_key = vs.' + @version_table_name + '_key
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
    ' + @version_table_name + '_version_key
  , ' + @version_table_name + '_key
  , ' + @version_grain_list + '
  , version_index
  , version_current_ind
  , version_latest_ind
  , end_version_dtmx
  , end_version_batch_key
  , end_source_rev_dtmx
  )  VALUES (
    vs.' + @version_table_name + '_version_key
  , vs.' + @version_table_name + '_key
  , ' + @x3_grain_list + '
  , vs.version_index
  , vs.version_current_ind
  , vs.version_latest_ind
  , vs.end_version_dtmx
  , vs.end_version_batch_key
  , vs.end_source_rev_dtmx
  )

;
'
  -- PRINT @sql
  EXECUTE sp_executesql @stmt = @sql;
  
END;
GO