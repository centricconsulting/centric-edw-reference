

/* ################################################################################

OBJECT: cdm.register

DESCRIPTION: Creates Data Management Process UID if it does not already exist in the cdmROC table.

PARAMETERS:

  @process_uid  = Text that uniquely identifies the Data Management process.
  
RETURN VALUE: None.
  
RETURN DATASET: None.

HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE procedure [cdm].[register]
  @process_uid VARCHAR(100)
AS
BEGIN

  -- determine if the process exists in the master table
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */  
  
  IF NOT EXISTS (SELECT 1 FROM cdm.process cdm where cdm.process_uid = @process_uid)
    AND @process_uid IS NOT NULL
  BEGIN
  
    BEGIN TRANSACTION;
    
    INSERT INTO cdm.process (process_uid) VALUES (@process_uid);
    
    COMMIT TRANSACTION;
    
  END;
    
END;
