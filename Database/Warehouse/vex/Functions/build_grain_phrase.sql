/* ################################################################################

OBJECT: vex.[build_version_grain_phrase].

DESCRIPTION: Each element of the delimited list is processed against the phrase pattern,
  replacing {value} with the element.  Individual phrases are concatenated into a single
  result phrase.

PARAMETERS:

  @version_table_name VARCHAR(200) = Name of the version table without the schema qualifier.

  @phrase_pattern VARCHAR(200) = Pattern applied to each column, resulting in a single phrase.
    The reserved text "{c}" will be replaced in the pattern by the column name.

  @delimiter VARCHAR(20) = Delimiter used to concatenate resultant phrases. No spaces or 
    other padding needs to be included in the delimiter.
  
OUTPUT PARAMETERS: None
  
RETURN VALUE:

  Returns VARCHAR(1000) = Phrase generated from the elements, transformed with a pattern and
    concatentaned into a resultant phrase.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2018-04-06  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE FUNCTION vex.build_grain_phrase (
  @table_name VARCHAR(200)
, @phrase_pattern VARCHAR(200)
, @delimiter VARCHAR(20) = ','
) RETURNS VARCHAR(1000) AS
BEGIN

  -- PHRASE PATTERN will replace "{c}" with the column name

  DECLARE 
    @grain_list TABLE(
      row_id INT IDENTITY(1,1)
    , column_name VARCHAR(200));

  INSERT INTO @grain_list (column_name)  
  SELECT c.name AS column_name FROM
  sys.tables t
  INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
  INNER JOIN sys.indexes i ON t.object_id = i.object_id
  INNER JOIN sys.index_columns ic ON
    ic.object_id  = i.object_id AND ic.index_id = i.index_id
  INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
  WHERE
  s.name = 'ver' AND t.name = @table_name
  AND i.type_desc = 'CLUSTERED'
  ORDER BY
  ic.index_column_id;

  DECLARE
    @row_id INT = 1
  , @max_row_id INT
  , @column_name VARCHAR(200)
  , @phrase VARCHAR(1000) = '';
  
  SELECT @max_row_id = MAX(row_id) FROM @grain_list;

  WHILE(@row_id <= @max_row_id)
  BEGIN

      SELECT @column_name = column_name
      FROM @grain_list
      WHERE row_id = @row_id;

      IF @row_id > 1
        SET @phrase = @phrase + ' ' + @delimiter + ' ';

      SET @phrase = @phrase + 
        REPLACE(@phrase_pattern, '{c}', @column_name);

      SET @row_id = @row_id + 1;

   END

   RETURN @phrase;

END