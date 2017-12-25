
/* ################################################################################

OBJECT: cdm.process_batch_initiate

DESCRIPTION: Given a Data Management Process UID this procedure initiates a new process batch.

PARAMETERS:

  @process_uid VARCHAR(200) = Text that uniquely identifies the Data Management process.

  @channel_uid VARCHAR(100) = The channel through which this data came into the system. Typically not specified. May be
    used when data comes in on file feeds (channel = file name) or when there are multiple source system instances
    loaded through a single workflow.
 
  @workflow_name VARCHAR(200) = Name of the workflow (encapsulated code) that executes the process.
 
  @workflow_guid VARCHAR(100) = Unique identifier of the workflow (encapsulated code) that executes the process.
 
  @workflow_version VARCHAR(20) = Version of the workflow (encapsulated code) that executes the process.
 
  @internal_sequence_ind BIT Optional = Flag that indicates whether to use the last successfully Completed Batch Key as the End Sequence Key.
    This creates efficiency by looking up the Completed Batch Key in the control tables rather than requiring it to be provided
    by the calling code.
 
  @increment_sequence_ind BIT Optional = Flag that indicates whether the Start Sequence Key is 
    incremented by one (1) over the previous End Sequence Key. 
 
  @current_sequence_val INT Optional = Integer value representing the current value (typically a maximum) 
    of the sequence key referenced by the source table.
  
  @current_sequence_dtm DATETIME Optional = Datetime value representing the current value
    (typically database server timestamp) of the Sequence Datetime referenced by the source table.
  
  @limit_process_uid VARCHAR(50) Optional = Identifier of a Data Management Process whose End Sequence Key is used to limit the
    returned End Sequence Key of the primary process.  The lesser of the two End Sequence Keys is returned.

  @comments VARCHAR(200) Optional = Comments to be applied to the new process batch.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE:

  process_batch_key INT = Key identifying the new process batch.

RETURN DATASET:

  NOTE: Only a single record will be returned.

  process_batch_key INT = Key identifying the new process batch.
  initiate_dtm DATETIME = Datetime the process batch was initiated.
  initiate_dtm_text CHAR(23) = Text representation of the Initiated Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  begin_sequence_val BIGINT = Integer value representing the start of the range to be considered in processing the batch.
  begin_sequence_dtm DATETIME = Datetime value representing the start of the range to be considered in processing the batch.
  begin_sequence_dtm_text CHAR(23) = Text representation of the Start Sequence Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  end_sequence_val BIGINT = Integer value representing the end of the range to be considered in processing the batch.
  end_sequence_dtm DATETIME = Datetime value representing the end of the range to be considered in processing the batch.
  end_sequence_dtm_text CHAR(23) = Text representation of the End Sequence Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE cdm.process_batch_initiate 
  @process_uid VARCHAR(100)
, @workflow_name VARCHAR(200)    
, @workflow_guid VARCHAR(100)
, @workflow_version VARCHAR(20)
, @internal_sequence_ind BIT = 0
, @increment_sequence_ind BIT = 1 
, @current_sequence_val BIGINT = NULL
, @current_sequence_dtm DATETIME = NULL  
, @limit_process_uid VARCHAR(200) = NULL
, @channel_uid VARCHAR(100) = NULL
, @limit_channel_uid VARCHAR(200) = NULL
, @scope VARCHAR(200) = NULL
AS
BEGIN  

  SET NOCOUNT ON -- added to ensure correct performance of SCOPE_IDENTITY

  DECLARE
    @process_batch_key INT
  , @initiate_dtm DATETIME
  , @prior_process_batch_key INT
  , @limit_process_batch_key INT
  , @begin_sequence_val BIGINT
  , @begin_sequence_dtm DATETIME
  , @end_sequence_val BIGINT
  , @end_sequence_dtm DATETIME  

  -- set the initiate DATETIME
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */     
  SET @initiate_dtm = CURRENT_TIMESTAMP;

  -- default channel values
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

  -- Channel UID is required
  IF @channel_uid IS NULL
  BEGIN
    SET @channel_uid = 'Primary';
  END

  -- Limit Channel UID is required only if a Limit Process UID exists
  -- Otherwise force Limit Channel UID to NULL
  IF @limit_process_uid IS NOT NULL
    IF @limit_channel_uid IS NULL SET @limit_channel_uid = 'Primary'
  ELSE
    SET @limit_channel_uid = NULL

  -- ensures that the process exists in the master table
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
    
  EXEC cdm.process_register @process_uid, @channel_uid

  -- generate a new batch key from the sequence
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  SET @process_batch_key = NEXT VALUE FOR [process_batch_key_provider]

  -- override the current sequence key and dtm with the current_process_batch_key, initiate_dtm
  -- if internal sequences are active otherwise use current parameters
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @internal_sequence_ind = 1
  BEGIN
    SET @current_sequence_val = @process_batch_key;
    SET @current_sequence_dtm = @initiate_dtm;
  END;
      
  -- determine start and end sequence values
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */    
  EXEC cdm.process_derive_sequence 
    @process_uid = @process_uid
  , @channel_uid = @channel_uid
  , @limit_process_uid = @limit_process_uid
  , @limit_channel_uid = @limit_channel_uid
  , @increment_sequence_ind = @increment_sequence_ind
  , @current_sequence_val = @current_sequence_val
  , @current_sequence_dtm = @current_sequence_dtm
  , @prior_process_batch_key = @prior_process_batch_key output 
  , @limit_process_batch_key = @limit_process_batch_key output
  , @begin_sequence_val = @begin_sequence_val output
  , @begin_sequence_dtm = @begin_sequence_dtm output
  , @end_sequence_val = @end_sequence_val output
  , @end_sequence_dtm = @end_sequence_dtm output
  
    
  -- insert into the process batch table
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */ 
  
  BEGIN TRANSACTION;
    
  INSERT INTO cdm.process_batch (
    process_batch_key
  , process_uid
  , channel_uid
  , [status]
  , completed_ind
  , initiate_dtm
  , current_sequence_val
  , current_sequence_dtm
  , prior_process_batch_key
  , begin_sequence_val
  , begin_sequence_dtm
  , limit_process_uid
  , limit_channel_uid
  , limit_process_batch_key
  , end_sequence_val
  , end_sequence_dtm
  , [scope]
  , workflow_name
  , workflow_guid
  , workflow_version
  ) values (
    @process_batch_key
  , @process_uid
  , @channel_uid
  , 'Started' -- status
  , NULL -- completed_ind
  , @initiate_dtm
  , @current_sequence_val
  , @current_sequence_dtm
  , @prior_process_batch_key
  , @begin_sequence_val
  , @begin_sequence_dtm
  , @limit_process_uid
  , @limit_channel_uid
  , @limit_process_batch_key
  , @end_sequence_val
  , @end_sequence_dtm
  , @scope
  , @workflow_name
  , @workflow_guid
  , @workflow_version
  );

  COMMIT TRANSACTION;
  
  SELECT
    @process_batch_key as process_batch_key
  , @initiate_dtm as initiate_dtm
  , CONVERT(char(23),@initiate_dtm,121) as initiate_dtm_text
  , @begin_sequence_val as begin_sequence_val
  , @begin_sequence_dtm as begin_sequence_dtm
  , @end_sequence_val as end_sequence_val
  , @end_sequence_dtm as end_sequence_dtm

  RETURN @process_batch_key;
  
END;
