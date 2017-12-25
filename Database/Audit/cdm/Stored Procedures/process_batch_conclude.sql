

/* ################################################################################

OBJECT: cdm.process_batch_conclude

DESCRIPTION: Given a Process Batch Key, conclude the batch indicating failure or success.

PARAMETERS:

  @process_batch_key INT = Key identifying the new process batch.

  @completed_ind BIT = Indicates whether the process completed successfully. 0=Failed, 1=Successful.
 
  @source_record_ct INT Optional = Count of records incoming from the source.

  @inserted_record_ct INT Optional = Count of records physically inserted into the target.

  @updated_record_ct INT Optional = Count of records physically updated in the target.

  @deleted_record_ct INT Optional = Count of records physically deleted in the target.

  @advanced_version_record_ct INT Optional = Count of records where a new version record was added.

  @collapsed_version_record_ct INT Optional = Count of records where a version record was collapsed.

  @revised_record_ct INT Optional = Count of records where a version record was revised.

  @unprocessed_record_ct INT Optional = Count of records that were not processed or ignored.

  @exception_record_ct INT Optional = Count of records that resulted in exceptions.

  @comments VARCHAR(2000) Optional = Comments related to the batch execution.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE [cdm].[process_batch_conclude]
  @process_batch_key INTEGER
, @completed_ind SMALLINT = 0
, @source_record_ct INTEGER = NULL
, @inserted_record_ct INTEGER = NULL
, @updated_record_ct INTEGER = NULL
, @deleted_record_ct INTEGER = NULL
, @advanced_version_record_ct INTEGER = NULL
, @collapsed_version_record_ct INTEGER = NULL
, @revised_record_ct INTEGER = NULL
, @unprocessed_record_ct INTEGER = NULL
, @exception_record_ct INTEGER = NULL
, @comments VARCHAR(2000) = NULL
AS
BEGIN

  -- set the status text according to flagss
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

  DECLARE @status VARCHAR(100);
  
  IF @completed_ind = 1
  BEGIN
  
    IF @exception_record_ct > 0
      SET @status = 'Completed With Exceptions';
    ELSE
      SET @status = 'Completed';
    
  END  
  ELSE
    SET @status = 'Failed';

  BEGIN TRANSACTION;  
  
  -- update the process batch record
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

  UPDATE cdm.process_batch SET
    [status] = @status
  , completed_ind = @completed_ind
  , source_record_ct = @source_record_ct
  , inserted_record_ct = @inserted_record_ct
  , updated_record_ct = @updated_record_ct
  , deleted_record_ct = @deleted_record_ct
  , advanced_version_record_ct = @advanced_version_record_ct
  , collapsed_version_record_ct = @collapsed_version_record_ct
  , revised_record_ct = @revised_record_ct  
  , unprocessed_record_ct = @unprocessed_record_ct
  , exception_record_ct = @exception_record_ct
  , conclude_dtm = CURRENT_TIMESTAMP
  , comments = @comments
  WHERE
  process_batch_key = @process_batch_key;
  
  -- if the batch completed successfull, update the process control
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */    
  
  -- handle completed, update process
  IF @completed_ind = 1
  BEGIN
      
    -- the completed sequences is taken from the limit of the corressponding process
    UPDATE p SET
      completed_process_batch_key = @process_batch_key
    , completed_sequence_val = pb.end_sequence_val
    , completed_sequence_dtm = pb.end_sequence_dtm
    , initiate_dtm = pb.initiate_dtm
    , conclude_dtm = pb.conclude_dtm
    FROM
    cdm.process p
    INNER JOIN cdm.process_batch pb ON
		pb.process_uid = p.process_uid 
		AND pb.channel_uid = p.channel_uid
    WHERE
    pb.process_batch_key = @process_batch_key
            
  END;

  COMMIT TRANSACTION;
  
END;
