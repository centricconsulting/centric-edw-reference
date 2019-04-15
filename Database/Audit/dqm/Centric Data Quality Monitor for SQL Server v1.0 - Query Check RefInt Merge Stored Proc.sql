--USE sample_warehouse
--go

/*
declare @return_key int
exec dqmon_execute @health_check_batch_key = @return_key output
exec dqmon_check_refint_merge
ec dqmon_batch_summary @return_key
*/
--  dqmon_check_refint_merge
-- select *  from dqmon where health_check_type like 'Referential%'

drop procedure cdm.dqmon_check_refint_merge
go

/* ################################################################################

OBJECT: dqmon_check_refint_merge

DESCRIPTION: inserts or updates referential health check queries.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create procedure cdm.dqmon_check_refint_merge as
begin

  set nocount on
  
  declare
    @primary_table_name varchar(200)
  , @primary_grain_column_list varchar(2000)
  , @primary_frame_ind bit
  , @foreign_table_name varchar(200)
  , @foreign_grain_column_list varchar(2000)
  , @foreign_frame_ind bit
  , @reverse_applicable_ind bit
  , @active_ind bit
  , @tag_list varchar(200)
  , @scope varchar(200)
  , @query varchar(2000)
  , @notes varchar(200)
  , @health_check_type varchar(100)
  , @value_text varchar(20)
  , @health_check_desc varchar(255)

  -- define a cursor of all active queries
  declare gen_list cursor fast_forward for
  select 
    primary_table_name
  , primary_grain_column_list
  , primary_frame_ind
  , foreign_table_name
  , foreign_grain_column_list
  , foreign_frame_ind
  , reverse_applicable_ind
  , active_ind
  , tag_list
  from
  cdm.dqmon_check_refint
  
  open gen_list
  
  -- get the first record  
  fetch gen_list into
    @primary_table_name
  , @primary_grain_column_list
  , @primary_frame_ind
  , @foreign_table_name
  , @foreign_grain_column_list
  , @foreign_frame_ind
  , @reverse_applicable_ind
  , @active_ind
  , @tag_list
  
  while @@fetch_status = 0
  begin

    set @value_text = 'Missing Records'

    -- generate and insert the referential integrity check
    set @notes = 'Automatically generated query. Primary grain is ' + @primary_grain_column_list + '.';
    set @health_check_type = 'Referential'
    set @health_check_desc = 'Check for referential integrity betweem ' 
      + @primary_table_name + ' (primary) and ' + @foreign_table_name + ' (foreign).'
    set @scope = @primary_table_name + ' --> ' + @foreign_table_name

    begin try
      set @query = cdm.dqmon_build_referential(
        @primary_table_name
      , @primary_grain_column_list
      , @primary_frame_ind
      , @foreign_table_name
      , @foreign_grain_column_list
      , @foreign_frame_ind)
    end try
    begin catch
      set @query = 'Unable to generate query.'
    end catch;

    exec cdm.dqmon_query_revise
      @health_check_desc
    , @health_check_type
    , @scope
    , 'Auto'
    , @notes
    , @value_text
    , @query
    , @tag_list
    , @active_ind;

    -- generate and insert the reverse referential integrity check if applicable
    if @reverse_applicable_ind = 1
    begin
        
      set @notes = 'Automatically generated query. Primary grain is ' + @foreign_grain_column_list + '.';
      set @health_check_type = 'Referential Reverse'
      set @health_check_desc = 'Check for referential integrity betweem ' 
        + @foreign_table_name + ' (primary) and ' + @primary_table_name + ' (foreign).'
      set @scope = @foreign_table_name + ' --> ' + @primary_table_name

      begin try
        set @query = cdm.dqmon_build_referential(
          @foreign_table_name
        , @foreign_grain_column_list
        , @foreign_frame_ind        
        , @primary_table_name
        , @primary_grain_column_list
        , @primary_frame_ind)
      end try
      begin catch
        set @query = 'Unable to generate query.'
      end catch;
        
      exec cdm.dqmon_query_revise
        @health_check_desc
      , @health_check_type
      , @scope
      , 'Auto'
      , @notes
      , @value_text
      , @query
      , @tag_list
      , @active_ind;

    end
    
    fetch gen_list into
      @primary_table_name
    , @primary_grain_column_list
    , @primary_frame_ind
    , @foreign_table_name
    , @foreign_grain_column_list
    , @foreign_frame_ind
    , @reverse_applicable_ind
    , @active_ind
    , @tag_list
      
  end;

  close gen_list
  deallocate gen_list
  
  
end

