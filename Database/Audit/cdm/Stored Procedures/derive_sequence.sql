

/* ################################################################################

OBJECT: cdm.derive_sequence

DESCRIPTION: Given a Data Management Process UID this procedure determines the 
  next Start and End Sequence Keys (or Datetimes) needed to bound incremental
  processing in the current execution of a cdmROC batch.

PARAMETERS:

  @process_uid VARCHAR(50) = Text that uniquely identifies the Data Management process.

  @limit_process_uid VARCHAR(50) Optional = Text that uniquely identifies the Data Management process 
    whose last Completed Sequence Key limits the derived End Sequence Key.
 
  @increment_sequence_ind BIT Optional = Flag that indicates whether the Start Sequence Key is 
    incremented by one (1) over the previous End Sequence Key. 
  
  @current_sequence_key BIGINT Optional = Integer value representing the current value (typically a maximum) 
    of the sequence key referenced by the source table.
  
  @current_sequence_dtm DATETIME Optional = Datetime value representing the current value
    (typically database server timestamp) of the Sequence Datetime referenced by the source table.
  
OUTPUT PARAMETERS:

  @prior_batch_key INT OUTPUT
  @limit_batch_key INT OUTPUT
  @start_sequence_key BIGINT OUTPUT
  @start_sequence_dtm DATETIME OUTPUT
  @end_sequence_key BIGINT OUTPUT
  @end_sequence_dtm DATETIME OUTPUT
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE [cdm].[derive_sequence] 

  @process_uid VARCHAR(100)
, @limit_process_uid VARCHAR(100) = NULL
, @increment_sequence_ind INTEGER = 1  
, @current_sequence_key BIGINT = NULL
, @current_sequence_dtm DATETIME = NULL

  -- output variables
, @prior_batch_key INT OUTPUT
, @limit_batch_key INT OUTPUT
, @start_sequence_key BIGINT OUTPUT
, @start_sequence_dtm DATETIME OUTPUT
, @end_sequence_key BIGINT OUTPUT
, @end_sequence_dtm DATETIME OUTPUT
  
AS
BEGIN

  DECLARE
    @default_sequence_key INTEGER
  , @default_sequence_dtm DATETIME

  SET @default_sequence_key = 0
  SET @default_sequence_dtm = CONVERT(datetime,'1900-01-01')
  
  -- ensures that the process and limit process
  -- exist in the master table
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
    
  EXEC cdm.register
    @process_uid
    
  IF @limit_process_uid IS NOT NULL
  BEGIN  
    EXEC cdm.register
      @limit_process_uid
  END
  
  
  -- start sequence values inerherited from the
  -- sequence last complete process
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */  
  
  SELECT
    @prior_batch_key = cdm.completed_batch_key
  , @start_sequence_key = cdm.completed_sequence_key
  , @start_sequence_dtm = cdm.completed_sequence_dtm
  FROM
  cdm.process cdm
  WHERE
  cdm.process_uid = @process_uid;
  
  
  -- increment the start sequence key according to flag
  -- this is typically used in cases where the sequences are external,
  -- but it also is applicable (though not required) for internal sequences.
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @increment_sequence_ind = 1
  BEGIN
   SET @start_sequence_key = @start_sequence_key + 1;
  END
     

  -- default start values only if they are missing.  this can
  -- occur on the first batch of a process.  
  -- in order to prevent generation of invalid data, the corresponding
  -- current sequence value must be non-null
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @start_sequence_key IS NULL AND @current_sequence_key IS NOT NULL
  BEGIN
    SET @start_sequence_key = @default_sequence_key;
  END;
  
  IF @start_sequence_dtm IS NULL AND @current_sequence_dtm IS NOT NULL
  BEGIN
    SET @start_sequence_dtm = @default_sequence_dtm;
  END;


  -- determine the end sequences from the limit
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @limit_process_uid IS NOT NULL
  BEGIN

    -- inherit the limit from a prior completed process
    SELECT
      @limit_batch_key = cdm.completed_batch_key
    , @end_sequence_key = cdm.completed_sequence_key
    , @end_sequence_dtm = cdm.completed_sequence_dtm
    FROM
    cdm.process cdm
    WHERE
    cdm.process_uid = @limit_process_uid;
    
  END;
  
  -- default end sequence values.
  -- if the end sequence key is not already assigned...
  -- or the end sequence key is greater than the current sequence key (except for text), ...
  -- set it to the current sequence key.
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

  IF @end_sequence_key IS NULL OR @end_sequence_key > @current_sequence_key
  BEGIN
    SET @end_sequence_key = @current_sequence_key;
  END;
  
  IF @end_sequence_dtm IS NULL OR @end_sequence_dtm > @current_sequence_dtm
  BEGIN
    SET @end_sequence_dtm = @current_sequence_dtm;
  END;
  
END;
