
/* ################################################################################

OBJECT: cdm.batch_error_log

DESCRIPTION: Logs an error associated with a Process Batch Key.

PARAMETERS:

  @batch_key INT = Key identifying the new process batch.

  @error_scope VARCHAR(200) = Scope of executing code where the error was raised.

  @error_type_cd CHAR(1) = Code indicating the type of error.  E=Critical Error, W=Warning, etc.
 
  @error_number INT = Number of the error reported.

  @error_message VARCHAR(2000) = Description of the error reported.

  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE cdm.batch_error_log
  @batch_key INT
, @error_scope VARCHAR(200)
, @error_type_cd CHAR(1)
, @error_number INTEGER
, @error_message VARCHAR(2000)
AS 
BEGIN

  BEGIN TRANSACTION;
  
  INSERT INTO batch_error (
    batch_key
  , error_scope
  , error_type_cd
  , error_number
  , error_message
  ) values (
    @batch_key
  , @error_scope
  , @error_type_cd
  , @error_number
  , @error_message
  );
  
  COMMIT TRANSACTION;

END;

