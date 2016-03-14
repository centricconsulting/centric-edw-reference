
/* ################################################################################

OBJECT: cdm.batch_initiate

DESCRIPTION: Given a Data Management Process UID this procedure initiates a new process batch.

PARAMETERS:

  @process_uid INT = Text that uniquely identifies the Data Management process.
 
  @workflow_name VARCHAR(200) = Name of the workflow (encapsulated code) that executes the process.
 
  @workflow_guid VARCHAR(100) = Unique identifier of the workflow (encapsulated code) that executes the process.
 
  @workflow_version VARCHAR(20) = Version of the workflow (encapsulated code) that executes the process.
 
  @internal_sequence_ind BIT Optional = Flag that indicates whether to use the last successfully Completed Batch Key as the End Sequence Key.
    This creates efficiency by looking up the Completed Batch Key in the control tables rather than requiring it to be provided
    by the calling code.
 
  @increment_sequence_ind BIT Optional = Flag that indicates whether the Start Sequence Key is 
    incremented by one (1) over the previous End Sequence Key. 
 
  @current_sequence_key INT Optional = Integer value representing the current value (typically a maximum) 
    of the sequence key referenced by the source table.
  
  @current_sequence_dtm DATETIME Optional = Datetime value representing the current value
    (typically database server timestamp) of the Sequence Datetime referenced by the source table.
  
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

CREATE PROCEDURE cdm.batch_initiate 
  @process_uid VARCHAR(100)
, @workflow_name VARCHAR(200)    
, @workflow_guid VARCHAR(100)
, @workflow_version VARCHAR(20)
, @internal_sequence_ind BIT = 0
, @increment_sequence_ind BIT = 1 
, @current_sequence_key BIGINT = NULL
, @current_sequence_dtm DATETIME = NULL  
, @limit_process_uid VARCHAR(100) = NULL
, @comments VARCHAR(200) = NULL
AS
BEGIN  

  SET NOCOUNT ON -- added to ensure correct performance of SCOPE_IDENTITY

  DECLARE
    @batch_key INT
  , @initiate_dtm DATETIME
  , @prior_batch_key INT
  , @limit_batch_key INT
  , @start_sequence_key BIGINT
  , @start_sequence_dtm DATETIME
  , @end_sequence_key BIGINT
  , @end_sequence_dtm DATETIME  

  -- set the frame DATETIME
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */     
  SET @initiate_dtm = CURRENT_TIMESTAMP;

  -- generate a new batch key from the sequence
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  SET @batch_key = NEXT VALUE FOR batch_provider

  -- override the current sequence key and dtm with the current_batch_key, initiate_dtm
  -- if internal sequences are active otherwise use current parameters
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @internal_sequence_ind = 1
  BEGIN
    SET @current_sequence_key = @batch_key;
    SET @current_sequence_dtm = @initiate_dtm;
  END;
      
  
  -- determine start and end sequence values
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */    
  EXEC cdm.derive_sequence 
    @process_uid
  , @limit_process_uid
  , @increment_sequence_ind
  , @current_sequence_key
  , @current_sequence_dtm
  , @prior_batch_key output
  , @limit_batch_key output
  , @start_sequence_key output
  , @start_sequence_dtm output
  , @end_sequence_key output
  , @end_sequence_dtm output
  
    
  -- insert into the process batch table
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */ 
  
  BEGIN TRANSACTION;
    
  INSERT INTO cdm.batch (
    batch_key
  , process_uid
  , status
  , completed_ind
  , initiate_dtm
  , current_sequence_key
  , current_sequence_dtm
  , prior_batch_key
  , start_sequence_key
  , start_sequence_dtm
  , limit_process_uid
  , limit_batch_key
  , end_sequence_key
  , end_sequence_dtm
  , workflow_name
  , workflow_guid
  , workflow_version
  , comments
  ) values (
    @batch_key
  , @process_uid
  , 'Started' -- status
  , 0 -- completed_ind
  , @initiate_dtm
  , @current_sequence_key
  , @current_sequence_dtm
  , @prior_batch_key
  , @start_sequence_key
  , @start_sequence_dtm
  , @limit_process_uid
  , @limit_batch_key
  , @end_sequence_key
  , @end_sequence_dtm
  , @workflow_name
  , @workflow_guid
  , @workflow_version
  , @comments
  );

  COMMIT TRANSACTION;
  
  SELECT
    @batch_key as batch_key
  , @initiate_dtm as initiate_dtm
  , CONVERT(char(23),@initiate_dtm,121) as initiate_dtm_text
  , @start_sequence_key as start_sequence_key
  , @start_sequence_dtm as start_sequence_dtm
  , CONVERT(char(23),@start_sequence_dtm,121) as start_sequence_dtm_text
  , @end_sequence_key as end_sequence_key
  , @end_sequence_dtm as end_sequence_dtm
  , CONVERT(char(23),@end_sequence_dtm,121) as end_sequence_dtm_text

  RETURN @batch_key;
  
END;
