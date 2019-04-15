--USE sample_warehouse
--go

/*
declare @return_key int
exec dqmon_execute @dqmon_batch_key = @return_key output
exec dqmon_batch_summary @return_key
*/
--  dqmon_execute_by_tag 'Error'

drop procedure cdm.dqmon_execute_by_tag
go

/* ################################################################################

OBJECT: dqmon_execute_by_tag

DESCRIPTION: executes dqmon queries having the 
  specified tag in their tag list and returns the results in a data set.

PARAMETERS:

@tag (Optional) = Specify the tag that will filter the health check queries executed.  If a tag
  is in the dq query's tag List, it will be included.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create procedure cdm.dqmon_execute_by_tag (
  @tag varchar(200)
) as
begin

  -- execute health check with tag filter, return batch key
  declare @dqmon_batch_key int  
  exec @dqmon_batch_key = cdm.dqmon_execute @tag = @tag
   
  -- return dataset of result for the batch
  select  
    dq.scope
  , dq.dqmon_type
  , dq.target_value  
  , dq.threshold_value
  , dqr.return_value
  , (dqr.return_value - dq.threshold_value) as threshold_variance
  , case 
      when dq.threshold_value = dqr.return_value then 0
      when dq.threshold_value > 0 then round(1.0*(dqr.return_value - dq.threshold_value) / dq.threshold_value,4)
    end as threshold_variance_pct
  , (dqr.return_value - dq.target_value) as target_variance      
  , case 
      when dq.target_value = dqr.return_value then 0  
      when dq.target_value > 0 then round(1.0*(dqr.return_value - dq.target_value) / dq.target_value,4)
    end as target_variance_pct
  , case when dqr.return_value > dq.target_value then 1 else 0 end as exceeded_target_ind
  , case when dqr.return_value > dq.threshold_value then 1 else 0 end as exceeded_threshold_ind
  , dqr.execution_duration_ms
  , dqr.error_message
  , dq.dqmon_desc
  , @dqmon_batch_key as dqmon_batch_key
  from
  cdm.dqmon_result dqr
  inner join cdm.dqmon_batch dqb on dqb.dqmon_batch_key = dqr.dqmon_batch_key
  inner join cdm.dqmon_query dq on dq.dqmon_query_key = dqr.dqmon_query_key
  where
  dqb.dqmon_batch_key = @dqmon_batch_key
  order by dq.scope, dq.dqmon_type

end;
