/* ################################################################################

OBJECT: vex.generic_table_settlement.

DESCRIPTION: Truncates corresponding VEX table and reloads it using settlement logic.

PARAMETERS:

  @version_table_name VARCHAR(200) = Unqualified table name (without schema) in the VER schema.  
    NOTE: Assumes that the CLUSTERED index of this table contains only grain columns.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE vex.generic_table_settlement 
  @version_table_name VARCHAR(100)
AS
BEGIN

  SET NOCOUNT ON

  -- Retrieve the grain column list for the table
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  DECLARE @version_grain_list VARCHAR(2000);
  SET @version_grain_list = vex.generate_version_grain_list(@version_table_name);

  -- Build the target grain list (used in insert columns)
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- NOTE: the "v." prefix is specificed in the reload query
  
  DECLARE @x1_grain_list VARCHAR(2000);
  SET @x1_grain_list = vex.generate_phrase(@version_grain_list, ',', 'v.{e}', ', ');

  -- Delete records from the target table
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  DECLARE @sql NVARCHAR(4000);

  SET @sql = N'TRUNCATE TABLE vex.[' + @version_table_name + ']';
  EXECUTE sp_executesql @stmt = @sql;
  --PRINT @sql

  -- Reload the target table
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  SET @sql = 
N'INSERT INTO vex.' + @version_table_name + ' (
  ' + @version_table_name + '_version_key
, ' + @version_table_name + '_key
, ' + @version_grain_list + '
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT
  v.' + @version_table_name + '_version_key

  -- THe first version key for the grain becomes the grain key
, MIN(v.' + @version_table_name + '_version_key)
    OVER (PARTITION BY ' + @x1_grain_list + ') AS ' + @version_table_name + '_key

, ' + @x1_grain_list + '

, ROW_NUMBER() OVER (PARTITION BY ' + @x1_grain_list + '
    ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) AS version_index

  -- XOR "^" inverts the deleted indicator
, LAST_VALUE(v.source_delete_ind) OVER (PARTITION BY ' + @x1_grain_list + '
    ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) ^ 1 AS version_current_ind

, CASE WHEN v.' + @version_table_name + '_version_key = LAST_VALUE(v.' + @version_table_name + '_version_key)
   OVER (PARTITION BY ' + @x1_grain_list + '
    ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (PARTITION BY ' + @x1_grain_list + '
    ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (PARTITION BY ' + @x1_grain_list + '
    ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (PARTITION BY ' + @x1_grain_list + '
    ORDER BY v.version_dtm, v.' + @version_table_name + '_version_key) AS end_source_rev_dtmx
FROM
ver.' + @version_table_name + ' v';

  EXECUTE sp_executesql @stmt = @sql;
  --PRINT @sql

END;
GO