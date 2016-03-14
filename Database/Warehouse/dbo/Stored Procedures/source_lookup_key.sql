/* ################################################################################

OBJECT: source_lookup_key

DESCRIPTION: Lookup a source key based on a Source UID.

PARAMETERS:

  @source_uid VARCHAR(20) = UID of the source.
  
RETURN VALUE: None.
  
RETURN DATASET:

  NOTE: Only a single record will be returned.

  source_key INT = Source Key corresponding to the provided UID.

HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2011-09-07  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE [dbo].[source_lookup_key]
  @source_uid varchar(20)
AS
BEGIN

  SET NOCOUNT ON

  SELECT s.source_key FROM map.source s
  WHERE s.source_uid = @source_uid;

END;


GO