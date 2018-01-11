/* ################################################################################

OBJECT: vex.[generate_phrase_grain_list].

DESCRIPTION: Generates a comma-delimited list of clustered index columns.

PARAMETERS:

  @version_table_name VARCHAR(1000) = Unqualified table name in the VER schema.
  
OUTPUT PARAMETERS: None
  
RETURN VALUE:

  Returns VARCHAR(2000) = Returns a comma delimited list of clustered index columns
    on the table in the VER schema.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE FUNCTION [vex].[generate_version_grain_list]
(
  @version_table_name VARCHAR(200)
)
RETURNS VARCHAR(2000) AS
BEGIN


  DECLARE @grain_column_table TABLE (column_name VARCHAR(200));

  DECLARE
    @version_grain_list VARCHAR(2000)
  , @result VARCHAR(2000);

  -- Get the clustered index columns (there can only be one clustered index per table)
  -- NOTE: Assumes that clustered index contains only Grain columns
  INSERT INTO @grain_column_table (column_name)
  SELECT c.name FROM
  sys.tables t 
  INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
  INNER JOIN sys.indexes ix ON ix.object_id = t.object_id
  INNER JOIN sys.index_columns ixc ON ixc.index_id = ix.index_id AND ixc.object_id = ix.object_id
  INNER JOIN sys.columns c ON c.column_id = ixc.column_id ANd c.object_id = ixc.object_id
  WHERE
  t.name = @version_table_name
  AND s.name = 'ver'
  AND ix.type_desc = 'CLUSTERED';

  -- Build the version grain list (used in Window functions)
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  -- NOTE: the "v." prefix is specificed in the reload query
  SELECT @version_grain_list = STUFF((

	  SELECT ',' + column_name FROM @grain_column_table
	  FOR XML PATH('')

  ), 1, 1, '');

  RETURN @version_grain_list;

END;