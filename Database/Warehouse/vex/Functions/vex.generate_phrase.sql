/* ################################################################################

OBJECT: vex.[generate_phrase].

DESCRIPTION: Each element of the delimited list is processed against the phrase pattern,
  replacing {value} with the element.  Individual phrases are concatenated into a single
  result phrase.

PARAMETERS:

  @delimited_list VARCHAR(1000) = Delimited list of text elements.

  @delimiter VARCHAR(20) = Delimter that separates elements in the delimited list.

  @phrase_pattern VARCHAR(200) = Pattern applied to each element, resulting in a single phrase.
    The reserved text "{e}" will be replaced in the pattern by the element.

  @phrase_delimiter VARCHAR(20) = Delimiter used to concatenate resultant phrases. No padding
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

CREATE FUNCTION [vex].[generate_phrase]
(
  @delimited_list VARCHAR(1000)
, @delimiter VARCHAR(20)
, @phrase_pattern VARCHAR(200)
, @phrase_delimiter VARCHAR(20)
)
RETURNS VARCHAR(2000) AS
BEGIN

  DECLARE
    @current_position INT = 1
  , @next_delimiter_position INT
  , @element varchar(200)
  , @delimiter_length INT = LEN(@delimiter)
  , @result VARCHAR(2000) = NULL

  WHILE @current_position <= LEN(@delimited_list)
  BEGIN

      -- determine the next delimiter position
      SET @next_delimiter_position = CHARINDEX(@delimiter, @delimited_list, @current_position)
  
      IF @next_delimiter_position = 0 
        SET @next_delimiter_position = LEN(@delimited_list)+1

      SET @element = LTRIM(RTRIM(
        SUBSTRING(@delimited_list, @current_position, @next_delimiter_position - @current_position)
      ))

      IF LEN(@element) > 0 
      BEGIN

        IF @result IS NULL 
          SET @result = REPLACE(@phrase_pattern, '{e}',@element)
        ELSE IF LEN(@element) > 0 
          SET @result = @result + @phrase_delimiter
            + REPLACE(@phrase_pattern, '{e}',@element)
                  
      END

      SET @current_position = @next_delimiter_position + @delimiter_length;

  END

  RETURN @result;

END
