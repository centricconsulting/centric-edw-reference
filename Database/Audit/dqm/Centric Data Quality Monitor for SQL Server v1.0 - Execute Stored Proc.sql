USE sample_warehouse
go

/*
declare @return_key int
exec dqmon_execute
exec dqmon_batch_summary @return_key
*/

drop procedure cdm.dqmon_execute
go

/* ################################################################################

OBJECT: dqmon_execute

DESCRIPTION: Cycles through active Health Check queries and stores the results for analysis.

PARAMETERS:

@tag (Optional) = Specify the tag that will filter the health check queries executed.  If a tag
  is in the dq query's Tag List, it will be included.
  
RETURN VALUE: Returns the Health Check Batch Key generated during execution.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-02-17  Jeff Kanel      1.0      Created

################################################################################ */

create procedure cdm.dqmon_execute (
  @tag varchar(200) = null   
) as
begin

  set nocount on

  declare
    @dqmon_batch_key int
  , @tag_filter varchar(202)
  , @rowdqmon_query_key int
  , @row_query varchar(2000)
  , @row_error_number int
  , @row_error_message varchar(2000)
  , @row_execution_start_dtm datetime
  , @row_execution_end_dtm datetime
  , @row_execution_result varchar(20)
  , @row_return_value int
  , @row_completed_ind bit
  , @row_version varchar(50);
  
  -- first refresh from the auto tables
  
  exec dqmon_check_refint_merge
  exec dqmon_check_grain_merge
  
  /*
  exec dqmon_error_check_merge
  exec dqmon_process_check_merge
  */
  
  -- create a tag filter if applicable
  if @tag is not null
    set @tag_filter = '%' + LTRIM(RTRIM(@tag)) + '%'

  -- always generate a new batch key, override incoming
  insert cdm.dqmon_batch default values;  
  set @dqmon_batch_key = SCOPE_IDENTITY()
  
  -- define a cursor of all active queries
  declare query_list cursor fast_forward for
  select 
    dq.dqmon_query_key
  , dq.query
  , dq.version
  from 
  cdm.dqmon_query dq
  where
  active_ind = 1
  and (
    @tag_filter is null
    or dq.tag_list like @tag_filter
  )
  
  -- create temporary table to store results
  create table #tmp_return_value (
	return_value int
  );    
  
  open query_list  
  fetch query_list into @rowdqmon_query_key, @row_query, @row_version
  
  while @@fetch_status = 0
  begin
    
    -- must clear the temp table of all rows
    truncate table #tmp_return_value
    
    -- initialize the values
    set @row_error_number = 0
    set @row_error_message = null
    set @row_return_value = null
    set @row_completed_ind = 0
    set @row_execution_start_dtm = getdate()    
  
    begin try
    
      exec('insert into #tmp_return_value ' + @row_query)
      
      set @row_execution_result = 'Successful'      
      select @row_return_value = max(return_value) from #tmp_return_value
      set @row_completed_ind = 1
    
    end try
    begin catch
    
      set @row_error_number = error_number()
      set @row_error_message = error_message()
      set @row_execution_result = 'Failed'
      
    end catch
    
    -- capture the end date
    set @row_execution_end_dtm = getdate()
    
    insert into cdm.dqmon_result (
	    dqmon_query_key
	  , dqmon_batch_key	    
	  , version
	  , execution_start_dtm
	  , execution_end_dtm
	  , execution_result
	  , return_value
	  , completed_ind
	  , error_number
	  , error_message
	  ) values (
	    @rowdqmon_query_key
	  , @dqmon_batch_key
	  , @row_version
	  , @row_execution_start_dtm
	  , @row_execution_end_dtm
	  , @row_execution_result
	  , @row_return_value
	  , @row_completed_ind
	  , @row_error_number
	  , @row_error_message
	  );

    fetch query_list into @rowdqmon_query_key, @row_query, @row_version
      
  end;
  
  close query_list
  deallocate query_list

  return @dqmon_batch_key
  
end;