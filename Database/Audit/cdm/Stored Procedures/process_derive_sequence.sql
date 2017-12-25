

/* ################################################################################

OBJECT: cdm.process_derive_sequence

DESCRIPTION: Given a Data Management Process UID this procedure determines the 
  next Start and End Sequence Keys (or Datetimes) needed to bound incremental
  processing in the current execution of a cdmROC batch.

PARAMETERS:

  @process_uid VARCHAR(50) = Text that uniquely identifies the Data Management process.

  @channel_uid = Text that uniquely identifies a tranche of data handled by the process.

  @scope = Text that may be used for analysis of process data, often used to group processes.

  @limit_process_uid VARCHAR(50) Optional = Text that uniquely identifies the Data Management process 
    whose last Completed Sequence Key limits the derived End Sequence Key.
 
  @increment_sequence_ind BIT Optional = Flag that indicates whether the Start Sequence Key is 
    incremented by one (1) over the previous End Sequence Key. 
  
  @current_sequence_val BIGINT Optional = Integer value representing the current value (typically a maximum) 
    of the sequence key referenced by the source table.
  
  @current_sequence_dtm DATETIME Optional = Datetime value representing the current value
    (typically database server timestamp) of the Sequence Datetime referenced by the source table.
  
OUTPUT PARAMETERS:

  @prior_process_batch_key INT OUTPUT
  @limit_process_batch_key INT OUTPUT
  @begin_sequence_val BIGINT OUTPUT
  @begin_sequence_dtm DATETIME OUTPUT
  @end_sequence_val BIGINT OUTPUT
  @end_sequence_dtm DATETIME OUTPUT
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE [cdm].[process_derive_sequence] 

  @process_uid VARCHAR(200)
, @channel_uid VARCHAR(200) = NULL
, @limit_process_uid VARCHAR(200) = NULL
, @limit_channel_uid VARCHAR(200) = NULL
, @increment_sequence_ind INTEGER = 1  
, @current_sequence_val BIGINT = NULL
, @current_sequence_dtm DATETIME = NULL

  -- output variables
, @prior_process_batch_key INT OUTPUT
, @limit_process_batch_key INT OUTPUT
, @begin_sequence_val BIGINT OUTPUT
, @begin_sequence_dtm DATETIME OUTPUT
, @end_sequence_val BIGINT OUTPUT
, @end_sequence_dtm DATETIME OUTPUT
  
AS
BEGIN

  -- NOTE: Channel UIDs are not defaulted in this proc
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

  DECLARE
    @default_sequence_val BIGINT
  , @default_sequence_dtm DATETIME

  SET @default_sequence_val = 0
  SET @default_sequence_dtm = CONVERT(datetime,'1900-01-01')
 
  -- start sequence values inerherited from the
  -- sequence last complete process
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */  
  
  SELECT
    @prior_process_batch_key = p.completed_process_batch_key
  , @begin_sequence_val = p.completed_sequence_val
  , @begin_sequence_dtm = p.completed_sequence_dtm
  FROM
  cdm.process p
  WHERE
  p.process_uid = @process_uid
  AND p.channel_uid = @channel_uid;
    
  -- increment the start sequence key according to flag
  -- this is typically used in cases where the sequences are external,
  -- but it also is applicable (though not required) for internal sequences.
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @increment_sequence_ind = 1
  BEGIN
   SET @begin_sequence_val = @begin_sequence_val + 1;
  END
     
  -- default start values only if they are missing.  this can
  -- occur on the first batch of a process.  
  -- in order to prevent generation of invalid data, the corresponding
  -- current sequence value must be non-null
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @begin_sequence_val IS NULL AND @current_sequence_val IS NOT NULL
  BEGIN
    SET @begin_sequence_val = @default_sequence_val;
  END;
  
  IF @begin_sequence_dtm IS NULL AND @current_sequence_dtm IS NOT NULL
  BEGIN
    SET @begin_sequence_dtm = @default_sequence_dtm;
  END;

  -- determine the end sequences from the limit
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
  
  IF @limit_process_uid IS NOT NULL AND @limit_channel_uid IS NOT NULL
  BEGIN

	-- inherit the limit from a prior completed process
	-- NOTE: it is conceivable that the limit process and channel do not exist
	--  which will results in a NULL End Sequence values
	SELECT
	  @limit_process_batch_key = p.completed_process_batch_key
	, @end_sequence_val = p.completed_sequence_val
	, @end_sequence_dtm = p.completed_sequence_dtm
	FROM
	cdm.process p
	WHERE
	p.process_uid = @limit_process_uid
	AND p.channel_uid = @limit_channel_uid;

  END;
  
  -- default end sequence values.
  -- if the end sequence key is not already assigned...
  -- or the end sequence key is greater than the current sequence key (except for text)...
  -- set it to the current sequence value.
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

  IF @end_sequence_val IS NULL OR @end_sequence_val > @current_sequence_val
  BEGIN
    SET @end_sequence_val = @current_sequence_val;
  END;
  
  IF @end_sequence_dtm IS NULL OR @end_sequence_dtm > @current_sequence_dtm
  BEGIN
    SET @end_sequence_dtm = @current_sequence_dtm;
  END;
  
END;
