

/* ################################################################################

OBJECT: cdm.batch_conclude

DESCRIPTION: Given a Process Batch Key, conclude the batch indicating failure or success.

PARAMETERS:

  @batch_key INT = Key identifying the new process batch.

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
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE [cdm].[batch_conclude]
  @batch_key INTEGER
, @completed_ind BIT = 0
, @source_record_ct INTEGER = NULL
, @inserted_record_ct INTEGER = NULL
, @updated_record_ct INTEGER = NULL
, @deleted_record_ct INTEGER = NULL
, @advanced_version_record_ct INTEGER = NULL
, @collapsed_version_record_ct INTEGER = NULL
, @revised_record_ct INTEGER = NULL
, @unprocessed_record_ct INTEGER = NULL
, @exception_record_ct INTEGER = NULL
AS
BEGIN

  DECLARE
    @status VARCHAR(50)
  , @process_uid VARCHAR(100);


  -- set the status text according to flagss
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @completed_ind = 1
  BEGIN
  
    IF @exception_record_ct > 0
      SET @status = 'Completed w. Exceptions';
    ELSE
      SET @status = 'Completed';
    
  END  
  ELSE
    SET @status = 'Failed';

  BEGIN TRANSACTION;  
  
  -- update the process batch record
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

  UPDATE cdm.batch SET
    status = @status
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
  WHERE
  batch_key = @batch_key;
  
  -- if the batch completed successfull, update the process control
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */    
  
  -- handle completed, update process
  IF @completed_ind = 1
  BEGIN
      
    -- the completed sequences is taken from the limit of the corressponding process
    UPDATE cdm SET
      completed_batch_key = @batch_key
    , completed_sequence_key = cdmb.end_sequence_key
    , completed_sequence_dtm = cdmb.end_sequence_dtm
    , initiate_dtm = cdmb.initiate_dtm
    , conclude_dtm = cdmb.conclude_dtm
    FROM
    cdm.process cdm
    INNER JOIN cdm.batch cdmb ON cdmb.process_uid = cdm.process_uid
    WHERE
    cdmb.batch_key = @batch_key
            
  END;

  COMMIT TRANSACTION;
  
END;
