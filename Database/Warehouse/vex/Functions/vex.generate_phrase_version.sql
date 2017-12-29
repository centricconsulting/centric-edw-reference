/* ################################################################################

OBJECT: vex.[generate_phrase_version].

DESCRIPTION: Generates a phrase from the clustered index column on a version table.

PARAMETERS:

  @version_table_name VARCHAR(1000) = Unqualified table name in the VER schema.

  @phrase_pattern VARCHAR(200) = Pattern applied to each element, resulting in a single phrase.
    The reserved text "{e}" will be replaced in the pattern by the element.

  @phrase_delimiter VARCHAR(20) = Delimiter used to concatenate resultant phrases.  No padding
    is applied to phrase delimiters.
  
OUTPUT PARAMETERS: None
  
RETURN VALUE:

  Returns VARCHAR(1000) = Phrase generated from the elements, transformed with a pattern and
    concatentaned into a resultant phrase.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE FUNCTION [vex].[generate_phrase_version]
(
  @version_table_name VARCHAR(1000)
, @phrase_pattern VARCHAR(200)
, @phrase_delimiter VARCHAR(20)
)
RETURNS VARCHAR(2000) AS
BEGIN

  -- Get the comma-delimited grain list
  DECLARE @version_grain_list VARCHAR(2000);
  SET @version_grain_list = vex.generate_version_grain_list(@version_table_name);

  DECLARE @result VARCHAR(2000)
  SET @result = vex.generate_phrase(@version_grain_list, ',', @phrase_pattern, @phrase_delimiter);

  RETURN @result;

END;