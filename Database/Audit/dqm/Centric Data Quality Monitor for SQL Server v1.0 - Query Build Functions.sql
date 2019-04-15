--use sample_warehouse
--go

/* ################################################################# */
drop function cdm.dqmon_alias_column_list
go


/* ################################################################################

OBJECT: dqmon_alias_column_list

DESCRIPTION: Applies aliases to a column-delimited list of columns
  
PARAMETERS:

@alias = Alias applied to all columns in the column list.
@@column_list = Comma-delimited list of columns.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_alias_column_list(
  @alias varchar(20)
, @column_list varchar(2000)
) returns varchar(2000) as
begin

  declare @retval varchar(2000)
  declare @prefix varchar(21)
  
  set @prefix = @alias + '.'
  
  set @retval = replace(replace(@column_list,' ',''), ',',', ' + @alias + '.')
  return @alias + '.' +  @retval
  
end
go

/* ################################################################# */

drop function cdm.dqmon_join_column_list
go

/* ################################################################################

OBJECT: dqmon_join_column_list

DESCRIPTION: Builds a join predicate based on two column lists.  Each column list
  must have the same number of columns or an error statement is returned in place
  of the predicate text.
  
PARAMETERS:

@operator = Operator (=, !=, <, >, etc.) applied to all comparisons in the predicate.
@alias1 = Alias applied to all columns in the first column list.
@column_list1 = Comma-delimited list of columns.
@alias2 = Alias applied to all columns in the second column list.
@column_list2 = Comma-delimited list of columns.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_join_column_list(
  @operator varchar(20)
, @alias1 varchar(20)  
, @column_list1 varchar(2000)  
, @alias2 varchar(20)  
, @column_list2 varchar(2000) = null
) returns varchar(2000) as
begin
  
  declare 
    @where varchar(2000)
  , @column1 varchar(100)
  , @column2 varchar(100)  
  , @position1 int
  , @position2 int  
  , @next_position1 int   
  , @next_position2 int   
  , @column_idx int

  if @column_list2 is null or len(@column_list2) = 0
    set @column_list2 = @column_list1

  -- prep column positions
  set @position1 = 0
  set @next_position1 = 1
  set @position2 = 0
  set @next_position2 = 1
  
  -- control looping with column list1 variables
  while (@next_position1 != 0 or @next_position2 != 0)
  begin
    
    -- strip out the column1
    set @next_position1 = CHARINDEX(',',@column_list1, @position1)
    
    if @next_position1 > 0 
    begin
    
      set @column1 = LTRIM(RTRIM(SUBSTRING(@column_list1,@position1,@next_position1 - @position1)))
      set @position1 = @next_position1 + 1
        
    end
    else
    begin
      set @column1 = RTRIM(LTRIM(SUBSTRING(@column_list1,@position1, LEN(@column_list1)-@position1 + 1)))
    end
    
    
    -- strip out the column2
    set @next_position2 = CHARINDEX(',',@column_list2, @position2)
    
    if @next_position2 > 0 
    begin
    
      set @column2 = LTRIM(RTRIM(SUBSTRING(@column_list2,@position2,@next_position2 - @position2)))             
      set @position2 = @next_position2 + 1
        
    end
    else
    begin
      set @column2 = LTRIM(RTRIM(SUBSTRING(@column_list2,@position2, LEN(@column_list2)-@position2 + 1)))    
    end    
    
    -- raise an error if column count is not the same between lists
    if (@next_position1 = 0 and @next_position2 != 0)
      or (@next_position1 != 0 and @next_position2 = 0)
      
      return '[Column lists do not contain the same number of columns]'

    -- build the join where clause
    if @where is null
      set @where = @alias1 + '.' + @column1 + ' ' + @operator + ' ' + @alias2 + '.' + @column2
    else
      set @where = @where + ' AND ' + @alias1 + '.' + @column1 + + ' ' + @operator + ' ' + @alias2 + '.' + @column2
        
  end
  
  return @where
  
end
go

/* ################################################################# */

drop function cdm.dqmon_build_version_collision
go

/* ################################################################################

OBJECT: dqmon_build_version_collision

DESCRIPTION: Checks for collisions in version tables.  Collisions are defined records 
  sharing a common set of grain values and having overlapping version Start/End date ranges.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_version_collision (
  @table_name varchar(100)
, @primary_column_list varchar(2000)
, @grain_column_list varchar(2000) 
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(1) AS collision_count FROM '
    + '(SELECT ' + @primary_column_list + ',' + @grain_column_list + ', version_start_dtm,ISNULL(version_end_dtmx,''12/31/2999'') AS version_end_dtmx '
    + 'FROM ' + @table_name + ') x1 INNER JOIN '
    + '(SELECT ' + + @primary_column_list + ',' + @grain_column_list + ', version_start_dtm,ISNULL(version_end_dtmx,''12/31/2999'') AS version_end_dtmx '
    + 'FROM ' + @table_name + ') x2 ON '
    + '(x1.version_start_dtm >= x2.version_start_dtm and x1.version_start_dtm < x2.version_end_dtmx) '
    + 'OR (x1.version_end_dtmx > x2.version_start_dtm and x1.version_end_dtmx <= x2.version_end_dtmx) '
    + 'WHERE ' + cdm.dqmon_join_column_list('!=','x1',@primary_column_list,'x2',null) + ' '
    + 'AND ' + cdm.dqmon_join_column_list('=','x1',@grain_column_list,'x2',null)
    
  return @sql

end
go

/* ################################################################# */

drop function cdm.dqmon_build_version_begin_gap
go

/* ################################################################################

OBJECT: dqmon_build_version_begin_gap

DESCRIPTION: Checks for gaps in version tables by analyzing the version Start Dates.  Gaps are defined records 
  sharing a common set of grain values and having a gap between the version End Date of one record and the
  version Start Date of the next.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_version_begin_gap (
  @table_name varchar(100)
, @primary_column_list varchar(2000)
, @grain_column_list varchar(2000) 
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(1) as start_gap_count FROM ' + @table_name + ' x1 '
  + 'WHERE version_end_dtmx IS NOT NULL AND NOT EXISTS '
  + '(SELECT 1 FROM ' + @table_name + ' x2 WHERE x2.version_start_dtm = x1.version_end_dtmx '
  + 'AND ' + cdm.dqmon_join_column_list('!=','x1',@primary_column_list,'x2',null) + ' '
  + 'AND ' + cdm.dqmon_join_column_list('=','x1',@grain_column_list,'x2',null)
  + ')'
    
  return @sql

end
go

/* ################################################################# */

drop function cdm.dqmon_build_version_end_gap
go

/* ################################################################################

OBJECT: dqmon_build_version_end_gap

DESCRIPTION: Checks for gaps in version tables by analyzing the version End Dates.  Gaps are defined records 
  sharing a common set of grain values and having a gap between the version End Date of one record and the
  version Start Date of the next.

PARAMETERS:

@table_name = Fully qualified name of the version table.
@primary_column_list = Comma-delimted list of primary key columns on the version table.
@grain_column_list = Comma-delimted list of grain columns on the version table.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_version_end_gap (
  @table_name varchar(100)
, @primary_column_list varchar(2000)
, @grain_column_list varchar(2000) 
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(1) as end_gap_count FROM ' + @table_name + ' x1 '
  + 'WHERE version_end_dtmx IS NOT NULL AND NOT EXISTS '
  + '(SELECT 1 FROM ' + @table_name + ' x2 WHERE x2.version_end_dtmx = x1.version_start_dtm '
  + 'AND ' + cdm.dqmon_join_column_list('!=','x1',@primary_column_list,'x2',null) + ' '
  + 'AND ' +  cdm.dqmon_join_column_list('=','x1',@grain_column_list,'x2',null) + ') AND EXISTS '
  + '(SELECT 1 FROM ' + @table_name + ' x2 GROUP BY ' +  cdm.dqmon_alias_column_list('x2',@grain_column_list) + ' '
  + 'HAVING MIN(x2.version_start_dtm) != x1.version_start_dtm '
  + 'AND ' + cdm.dqmon_join_column_list('=','x1',@grain_column_list,'x2',null) + ')'
    
  return @sql

end
go

/* ################################################################# */

drop function cdm.dqmon_build_version_duplicate_current
go

/* ################################################################################

OBJECT: dqmon_build_version_duplicate_current

DESCRIPTION: Checks version tables where the records for a given grain have more than 
  one record with a Current Record Indicator = 1.
  
PARAMETERS:

@table_name = Fully qualified name of the version table.
@grain_column_list = Comma-delimted list of grain columns on the version table.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_version_duplicate_current (
  @table_name varchar(100)
, @grain_column_list varchar(2000) 
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(1) as duplicate_count FROM (' 
  + 'SELECT ' +  cdm.dqmon_alias_column_list('x1',@grain_column_list) + ' '
  + 'FROM ' + @table_name + ' x1 WHERE x1.version_latest_ind = 1 ' 
  + 'GROUP BY ' + cdm.dqmon_alias_column_list('x1',@grain_column_list) + ' HAVING COUNT(1) > 1'
  + ') x'
    
  return @sql

end
go

/* ################################################################# */

drop function cdm.dqmon_build_version_duplicate_latest
go

/* ################################################################################

OBJECT: dqmon_build_version_duplicate_latest

DESCRIPTION: Checks version tables where the records for a given grain have more than 
  one record with a Latest Record Indicator = 1.
  
PARAMETERS:

@table_name = Fully qualified name of the version table.
@grain_column_list = Comma-delimted list of grain columns on the version table.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_version_duplicate_latest (
  @table_name varchar(100)
, @grain_column_list varchar(2000) 
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(1) as duplicate_count FROM (' 
  + 'SELECT ' +  cdm.dqmon_alias_column_list('x1',@grain_column_list) + ' '
  + 'FROM ' + @table_name + ' x1 WHERE x1.version_latest_ind = 1 ' 
  + 'GROUP BY ' + cdm.dqmon_alias_column_list('x1',@grain_column_list) + ' HAVING COUNT(1) > 1'
  + ') x'
    
  return @sql

end
go


/* ################################################################# */

drop function cdm.dqmon_build_referential
go

/* ################################################################################

OBJECT: dqmon_build_referential

DESCRIPTION: Checks version tables where the records for a given grain have more than 
  one record.  If either the Foreign or Primary table is a version Table (has Current Record Indicator column) then
  the filter "version_latest_ind = 1" is applied accordingly.

PARAMETERS:

@primary_table_name = Fully qualified  name of the table containing the complete set of records.
@primary_grain_column_list = Comma-delimited list of columns representing the grain of the Primary Table.
@primary_version_ind = Flag indicating if the Primary Table has a version_latest_ind column, indicating a version table.(1=True,0=False)
@foreign_table_name = Fully qualified name of the table to be checked whether it contains a complete set of records.
@foreign_grain_column_list = Comma-delimited list of columns representing the grain of the Foreign Table.
@foreign_version_ind bit = Flag indicating if the Foreign Table has a version_latest_ind column, indicating a version table.(1=True,0=False)

HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_referential (
  @primary_table_name varchar(200)
, @primary_grain_column_list varchar(2000)
, @primary_version_ind bit
, @foreign_table_name varchar(200)
, @foreign_grain_column_list varchar(2000)
, @foreign_version_ind bit 
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(*) FROM ' + @primary_table_name + ' x1 ' 
  + 'WHERE NOT EXISTS ('
  + 'SELECT 1 FROM ' + @foreign_table_name + ' x2 '
  + 'WHERE ' + cdm.dqmon_join_column_list('=','x2',@foreign_grain_column_list,'x1',@primary_grain_column_list) 
  + case when @foreign_version_ind = 1 THEN ' AND x2.version_latest_ind = 1' else '' end
  + ') ' + case when @primary_version_ind = 1 THEN ' AND x1.version_latest_ind = 1' else '' end
    
  return @sql

end
go



/* ################################################################# */

drop function cdm.dqmon_build_duplicate_grain
go

/* ################################################################################

OBJECT: dqmon_build_duplicate_grain

DESCRIPTION: Checks a table to determine if a set of grain values occurs more than once. If the table 
  is a version Table (has Current Record Indicator column) then the filter "version_latest_ind = 1" is applied accordingly.
  
PARAMETERS:

@table_name = Fully qualified name of the version table.
@grain_column_list = Comma-delimted list of grain columns on the version table.
@version_table_ind = Flag indicating if the table has a version_latest_ind column, indicating a version table.(1=True,0=False)
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_duplicate_grain (
  @table_name varchar(100)
, @grain_column_list varchar(2000) 
, @version_table_ind bit = 0
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(1) as duplicate_count FROM (' 
  + 'SELECT ' +  cdm.dqmon_alias_column_list('x1',@grain_column_list) + ' '
  + 'FROM ' + @table_name + ' x1 ' 
  + CASE WHEN @version_table_ind = 1 THEN 'WHERE version_latest_ind = 1 ' END
  + 'GROUP BY ' + cdm.dqmon_alias_column_list('x1',@grain_column_list) + ' HAVING COUNT(1) > 1'
  + ') x'
    
  return @sql

end
go

/* ################################################################# */

drop function cdm.dqmon_build_error
go

/* ################################################################################

OBJECT: dqmon_build_error

DESCRIPTION: Checks an error table to determine if records exist in the past hours as indicated by the parameter.
  
PARAMETERS:

@table_name = Fully qualified name of the version table.
@dtm_column_name = Name of the column holding the reference datetime value.
@hours_ago = Number of hours prior to the current time  included in consideration.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_error (
  @table_name varchar(100)
, @dtm_column_name varchar(100)
, @hours_ago int
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT COUNT(1) FROM ' + @table_name + ' WHERE ' + @dtm_column_name + ' '
    + 'BETWEEN DATEADD(hour,-' + CAST(@hours_ago AS varchar(10)) + ',CURRENT_TIMESTAMP) AND CURRENT_TIMESTAMP'
    
  return @sql

end
go

/* ################################################################# */

drop function cdm.dqmon_build_process_rejected
go

/* ################################################################################

OBJECT: dqmon_build_process_rejected

DESCRIPTION: Checks a process, counting the number of
  rejected rows across all process instances executed in the past 18 hours.
  
PARAMETERS:

@process_name = Name of an ETL process.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_process_rejected (
  @process_name varchar(100)
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  /*
  set @sql = 'SELECT SUM(pl.RowsRejected) as rows_rejected FROM Base.cdm.dmproc pl '
    + 'INNER JOIN base.cdm.dmproc_batch pc ON pl.dmproc_uid = pc.dmproc_uid AND pl.dmproc_batch_key = pc.ProcessKey '
    + 'WHERE pl.ProcessStartDtm BETWEEN DATEADD(hour,-18,CURRENT_TIMESTAMP) AND CURRENT_TIMESTAMP '
    + 'AND pc.ProcessName = ''' + @process_name + ''''
  */
  
  set @sql = 'SELECT 0 AS Count'
    
  return @sql

end
go



/* ################################################################# */

drop function cdm.dqmon_build_process_excessive
go

/* ################################################################################

OBJECT: dqmon_build_process_excessive

DESCRIPTION: Checks a process, counting the number of
  rows inserted in excess of 5% or source rows.
  
PARAMETERS:

@process_name = Name of an ETL process.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_process_excessive (
  @process_name varchar(100)
, @rows_processed_ratio numeric(6,4)
, @hours_ago int
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)

  set @sql = 'SELECT CASE WHEN '
    + 'SUM(inserted_record_ct + updated_record_ct + revised_record_ct + advanced_version_record_ct - source_record_ct *' 
	+ CAST(@rows_processed_ratio AS varchar(20)) + ') <= 0 THEN 0 '
    + 'ELSE SUM(inserted_record_ct + updated_record_ct + revised_record_ct + advanced_version_record_ct - source_record_ct *' 
	+ CAST(@rows_processed_ratio AS varchar(20)) + ') END '
    + 'AS excessive_rows FROM cdm.dmproc_batch pl '
    + 'WHERE pl.initiate_dtm BETWEEN DATEADD(hour,-' + CAST(@hours_ago AS varchar(10)) + ',CURRENT_TIMESTAMP) AND CURRENT_TIMESTAMP '
    + 'AND pl.dmproc_uid = ''' + @process_name + ''''
    
  return @sql

end
go

/* ################################################################# */

drop function cdm.dqmon_build_process_execution
go


/* ################################################################################

OBJECT: dqmon_build_process_execution

DESCRIPTION: Checks a process, counting the number of
  process instances executed in the past indicated hours.
  
PARAMETERS:

@process_name = Name of an ETL process.
@hours_ago = N
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_process_execution (
  @process_name varchar(100)
, @hours_ago int
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)
  
   set @sql = 'SELECT COUNT(1) as process_executions FROM cdm.dmproc pc WHERE '
    + 'initiate_dtm >= DATEADD(h,-' + CAST(@hours_ago as varchar(20)) + ',CURRENT_TIMESTAMP) '
    + 'AND pc.dmproc_uid = ''' + @process_name + ''''
        
  return @sql

end
go



/* ################################################################# */

drop function cdm.dqmon_build_process_silent
go

/* ################################################################################

OBJECT: dqmon_build_process_execution

DESCRIPTION: Checks a process in the Process Control table, returning the value 1 if
  the process has not been executed in the past 18 hours.
  
PARAMETERS:

@process_name = Name of an ETL process.
@hours_ago = Number of hours prior to the current time included in consideration.
  
HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2010-05-19  Jeff Kanel      1.0      Created

################################################################################ */

create function cdm.dqmon_build_process_silent (
  @process_name varchar(100)
, @hours_ago int
) returns varchar(2000) as
begin
  
  declare @sql varchar(2000)
  
   set @sql = 'SELECT COUNT(1) as process_executions FROM cdm.dmproc pc WHERE '
    + 'initiate_dtm < DATEADD(h,-' + CAST(@hours_ago as varchar(20)) + ',CURRENT_TIMESTAMP) '
    + 'AND pc.dmproc_uid = ''' + @process_name + ''''
        
  return @sql

end
go