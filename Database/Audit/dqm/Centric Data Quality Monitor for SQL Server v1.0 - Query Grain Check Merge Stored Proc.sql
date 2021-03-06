--USE sample_warehouse
--GO

/****** Object:  StoredProcedure [dbo].dqmon_grain_check_merge    Script Date: 05/26/2011 16:44:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ################################################################################

OBJECT: dqmon_check_grain_merge

DESCRIPTION: inserts or updates version-related health check queries.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

drop procedure cdm.dqmon_check_grain_merge
go

CREATE procedure cdm.dqmon_check_grain_merge as
begin

  set nocount on
  
  declare
    @table_name varchar(200)
  , @key_column_list varchar(2000)
  , @grain_column_list varchar(2000)
  , @tag_list varchar(200)
  , @query varchar(2000)
  , @version_ind bit
  , @notes varchar(200)
  , @dqmon_type varchar(100)
  , @value_text varchar(20)
  , @dqmon_desc varchar(255)
  , @active_ind bit

  -- define a cursor of all active queries
  declare gen_list cursor fast_forward for
  select 
    table_name
  , key_column_list
  , grain_column_list
  , version_ind
  , active_ind
  , tag_list    
  from
  cdm.dqmon_check_grain
  
  open gen_list
  
  -- get the first record  
  fetch gen_list into
    @table_name
  , @key_column_list
  , @grain_column_list
  , @version_ind
  , @active_ind
  , @tag_list   
  
  while @@fetch_status = 0
  begin

    set @notes = 'Automatically generated query. Grain is ' + @grain_column_list + '.';

    -- only process queries if the version indicator is on
    if @version_ind = 1
    begin
    
      -- insert version duplicate current checks    
      set @dqmon_type = 'Version Duplicate Latest'
      set @value_text = 'Duplicates'
      set @dqmon_desc = 'Check for duplicate current records on ' + @table_name + '.'
      
      begin try
        set @query = cdm.dqmon_build_version_duplicate_latest(@table_name, @grain_column_list)
      end try
      begin catch
        set @query = 'Unable to generate query.'
      end catch;
      
      exec cdm.dqmon_query_revise
        @dqmon_desc
      , @dqmon_type
      , @table_name
      , 'Auto'
      , @notes
      , @value_text
      , @query
      , @tag_list
      , @active_ind;
      
      -- insert version version collision checks    
      set @dqmon_type = 'Version Collision'
      set @value_text = 'Collisions'
      set @dqmon_desc = 'Check for collision of Version Start and End Dates on ' + @table_name + '.'
      
      begin try
        set @query = cdm.dqmon_build_version_collision(@table_name, @key_column_list, @grain_column_list)
      end try
      begin catch
        set @query = 'Unable to generate query.'
      end catch      
      
      exec cdm.dqmon_query_revise
        @dqmon_desc
      , @dqmon_type
      , @table_name
      , 'Auto'
      , @notes
      , @value_text
      , @query
      , @tag_list
      , @active_ind;
      
      -- insert version version start gap checks    
      set @dqmon_type = 'Version Begin Gap'
      set @value_text = 'Gaps'
      set @dqmon_desc = 'Check for gaps between Versions on ' + @table_name + '.'
      
      begin try
        set @query = cdm.dqmon_build_version_begin_gap(@table_name, @key_column_list, @grain_column_list)
      end try
      begin catch
        set @query = 'Unable to generate query.'
      end catch    
            
      exec cdm.dqmon_query_revise
        @dqmon_desc
      , @dqmon_type
      , @table_name
      , 'Auto'
      , @notes
      , @value_text
      , @query
      , @tag_list
      , @active_ind;
       
      
      -- insert version version end gap checks    
      set @dqmon_type = 'Version End Gap'
      set @value_text = 'Gaps'
      set @dqmon_desc = 'Check for gaps between Versions on ' + @table_name + '.'
      
      begin try
        set @query = cdm.dqmon_build_version_end_gap(@table_name, @key_column_list, @grain_column_list)
      end try
      begin catch
        set @query = 'Unable to generate query.'
      end catch    
      
      exec cdm.dqmon_query_revise
        @dqmon_desc
      , @dqmon_type
      , @table_name
      , 'Auto'
      , @notes
      , @value_text
      , @query
      , @tag_list
      , @active_ind;
       
    end
    else
    begin
    
      -- insert a check for duplicate grains
      set @dqmon_type = 'Duplicate Grain'
      set @value_text = 'Duplicates'
      set @dqmon_desc = 'Check for duplicate grain records on ' + @table_name + '.'
      
      begin try
        set @query = cdm.dqmon_build_duplicate_grain(@table_name, @grain_column_list, @version_ind)
      end try
      begin catch
        set @query = 'Unable to generate query.'
      end catch    
      
      exec cdm.dqmon_query_revise
        @dqmon_desc
      , @dqmon_type
      , @table_name
      , 'Auto'
      , @notes
      , @value_text
      , @query
      , @tag_list
      , @active_ind;
      
          
    end

    fetch gen_list into
      @table_name
    , @key_column_list
    , @grain_column_list
    , @version_ind
    , @active_ind
    , @tag_list; 
      
  end;

  close gen_list
  deallocate gen_list
  
  
end

