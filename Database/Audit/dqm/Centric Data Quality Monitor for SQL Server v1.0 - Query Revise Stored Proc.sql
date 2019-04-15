--USE sample_warehouse
--go

drop procedure cdm.dqmon_query_revise
go

/* ################################################################################

OBJECT: dqmon_query_revise

DESCRIPTION: inserts or updates health check queries.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create procedure cdm.dqmon_query_revise (
  @dqmon_desc varchar(255)  
, @dqmon_type varchar(200)
, @scope varchar(50)
, @version varchar(20)
, @notes varchar(200)
, @value_text varchar(50)
, @query varchar(2000)
, @tag_list varchar(200)
, @active_ind bit
, @overwrite_tag_list_on_update bit = 1
)
as
begin

  set nocount on
  
  -- if the query already exists (identified by type, scope and version), update key values
  -- otherwise insert the query
  if exists (
    select 1 from cdm.dqmon_query dq where
    dq.dqmon_type = @dqmon_type
    AND dq.scope = @scope
    AND dq.version = @version
  )
  begin
  
    if @overwrite_tag_list_on_update = 1
    
      update cdm.dqmon_query set value_text = @value_text, query = @query, tag_list = @tag_list
      where dqmon_type = @dqmon_type AND scope = @scope AND version = @version    
    
    else

      update cdm.dqmon_query set value_text = @value_text, query = @query
      where dqmon_type = @dqmon_type AND scope = @scope AND version = @version       
    
  end   
  else
           
    insert into cdm.dqmon_query (
      dqmon_desc
    , dqmon_type
    , scope
    , version
    , notes
    , active_ind
    , target_value
    , threshold_value
    , value_text
    , query
    , tag_list
    ) values (
      @dqmon_desc
    , @dqmon_type
    , @scope
    , @version
    , @notes
    , @active_ind
    , 0
    , 0
    , @value_text
    , @query
    , @tag_list
    );

end