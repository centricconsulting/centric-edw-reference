

/* ################################################################################

OBJECT: cdm.process_register

DESCRIPTION: Creates Data Management Process UID if it does not already exist in the cdmROC table.

PARAMETERS:

  @process_uid  = Text that uniquely identifies the Data Management process.

  @channel_uid = Text that uniquely identifies a tranche of data handled by the process.

  @context = Text that may be used for analysis of process data, often used to group processes.
    
RETURN VALUE: None.
  
RETURN DATASET: None.

HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE procedure [cdm].[process_register]
  @process_uid VARCHAR(200)
, @channel_uid VARCHAR(200) = NULL
AS
BEGIN

  -- determine if the process exists in the master table
  -- update the context if it is different than expected
  /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */  
  
    -- default the channel value if not provided
    IF @channel_uid IS NULL
	  SET @channel_uid = 'Primary';

	MERGE
	  cdm.process AS target  

	USING 
	  (

	    SELECT
	      @process_uid AS process_uid
	    , @channel_uid AS channel_uid

	  ) AS source

	ON target.process_uid = source.process_uid 
	  AND target.channel_uid = source.channel_uid

	WHEN NOT MATCHED BY TARGET THEN 

	  INSERT (process_uid, channel_uid, context)
	  VALUES (source.process_uid, source.channel_uid, 'General')
	;
    
END;
