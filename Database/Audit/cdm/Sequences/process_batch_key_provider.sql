/* ################################################################################

OBJECT: cdm.process_batch_key_sequence

DESCRIPTION: Sequence provider for new Process Batch Keys.

RETURN VALUE: 

  Returns integer value that is next in the sequence
  USAGE: SET @process_batch_key = NEXT VALUE FOR [process_batch_key_provider]
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------------------------
  2017-12-25  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE SEQUENCE [cdm].[process_batch_key_provider]
    AS BIGINT
    START WITH 1
    INCREMENT BY 1
    CACHE 50;

