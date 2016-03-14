
/* ################################################################################

OBJECT: cdm.batch_initiate_internal

DESCRIPTION: Given a Data Management Process UID this procedure initiates a new process batch, automatically
  applying the Internal Sequence Indicator = 1.

PARAMETERS:

  @process_uid = Text that uniquely identifies the Data Management process.
 
  @workflow_name = Name of the workflow (encapsulated code) that executes the process.
 
  @workflow_guid VARCHAR(100) = Unique identifier of the workflow (encapsulated code) that executes the process.
 
  @workflow_version VARCHAR(20) = Version of the workflow (encapsulated code) that executes the process.
  
  @limit_process_uid VARCHAR(50) Optional = Identifier of a Data Management Process whose End Sequence Key is used to limit the
    returned End Sequence Key of the primary process.  The lesser of the two End Sequence Keys is returned.

  @comments VARCHAR(200) Optional = Comments to be applied to the new process batch.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE:

  batch_key INT = Key identifying the new process batch.

RETURN DATASET:

  NOTE: Only a single record will be returned.

  batch_key INT = Key identifying the new process batch.
  initiate_dtm DATETIME = Datetime the process batch was initiated.
  initiate_dtm_text CHAR(23) = Text representation of the Initiated Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  start_sequence_key BIGINT = Integer value representing the start of the range to be considered in processing the batch.
  start_sequence_dtm DATETIME = Datetime value representing the start of the range to be considered in processing the batch.
  start_sequence_dtm_text CHAR(23) = Text representation of the Start Sequence Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  end_sequence_key BIGINT = Integer value representing the end of the range to be considered in processing the batch.
  end_sequence_dtm DATETIME = Datetime value representing the end of the range to be considered in processing the batch.
  end_sequence_dtm_text CHAR(23) = Text representation of the End Sequence Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE cdm.batch_initiate_internal
  @process_uid VARCHAR(100)
, @workflow_name VARCHAR(200)    
, @workflow_guid VARCHAR(100)
, @workflow_version VARCHAR(20)
, @limit_process_uid VARCHAR(100) = NULL
, @comments VARCHAR(200) = NULL 
AS
BEGIN

  
  EXEC cdm.batch_initiate 
    @process_uid
  , @workflow_name
  , @workflow_guid
  , @workflow_version
  , 1 -- @internal_sequence_ind
  , 1 -- @increment_sequence_ind 
  , NULL -- @current_sequence_key
  , NULL -- @current_sequence_dtm
  , @limit_process_uid
  , @comments
  
END
