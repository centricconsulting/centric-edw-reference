/* ################################################################################

OBJECT: dbo.calendar_rebuild

DESCRIPTION: Truncates and rebuilds the calendar table.  Includes the unknown and indefinite date records.

PARAMETERS:

    @begin_year INT = First year of the calendar.
    @end_year INT = Last year of the calendar.
  
RETURN VALUE: None.
  
RETURN DATASET: None.

HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2016-03-15  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE dbo.calendar_rebuild
  @begin_year int
, @end_year int
AS
BEGIN

  SET NOCOUNT ON

  declare
    @source_key int = 0
  , @source_revision_actor varchar(20) = 'SYSTEM'
  , @current_dt date
  , @current_date_key int
  , @last_dt date
  , @current_holiday_ind int
  , @current_weekend_ind int
  , @current_day_of_week int
  ;
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- completely clear out the calendar table
  
  TRUNCATE TABLE dbo.calendar;


  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert indefinite and unknown records

  declare
    @unknown_text varchar(20) = 'Unknown'
  , @unknown_key int = 0
  , @indefinite_text varchar(20) = 'Indefinite'
  , @indefinite_key int = 99999999
  , @indefinite_key_6digit int = 999999
  , @indefinite_key_4digit int = 9999
  ;

  INSERT INTO calendar (
    date_key
  , day_desc_01
  , day_desc_02
  , day_desc_03
  , day_desc_04
  , weekday_desc_01
  , weekday_desc_02
  
  , week_key
  , week_desc_01
  , week_desc_02
  , week_desc_03
  , week_desc_04

  , month_key
  , month_desc_01
  , month_desc_02
  , month_desc_03
  , month_desc_04
  , month_of_year_desc_01
  , month_of_year_desc_02

  , quarter_key
  , quarter_desc_01
  , quarter_desc_02
  , quarter_desc_03
  , quarter_desc_04
  , quarter_of_year_desc_01
  , quarter_of_year_desc_02

  , year_key
  , year_desc_01
  , year_desc_02

  , source_key
  , source_revision_actor
  , source_revision_dtm

  , init_process_batch_key
  , process_batch_key

  )
  VALUES (
    -- UNKNOWN RECORD
    @unknown_key -- date_key
  , @unknown_text -- day_desc_01
  , @unknown_text -- day_desc_02
  , @unknown_text -- day_desc_03
  , @unknown_text -- day_desc_04
  , @unknown_text -- weekday_desc_01
  , @unknown_text -- weekday_desc_02

  , @unknown_key -- week_key
  , @unknown_text -- week_desc_01
  , @unknown_text -- week_desc_02
  , @unknown_text -- week_desc_03
  , @unknown_text -- week_desc_04

  , @unknown_key -- month_key
  , @unknown_text -- month_desc_01
  , @unknown_text -- month_desc_02
  , @unknown_text -- month_desc_03
  , @unknown_text -- month_desc_04
  , @unknown_text -- month_of_year_desc_01
  , @unknown_text -- month_of_year_desc_02

  , @unknown_key -- quarter_key
  , @unknown_text -- quarter_desc_01
  , @unknown_text -- quarter_desc_02
  , @unknown_text -- quarter_desc_03
  , @unknown_text -- quarter_desc_04
  , @unknown_text -- quarter_of_year_desc_01
  , @unknown_text -- quarter_of_year_desc_02

  , @unknown_key -- year_key
  , @unknown_text -- year_desc_01
  , @unknown_text -- year_desc_02  
  
  , @source_key -- source_key
  , @source_revision_actor -- source_revision_actor
  , CURRENT_TIMESTAMP -- source_revision_dtm

  , @unknown_key -- init_process_batch_key
  , @unknown_key -- process_batch_key

  ) , (
    -- INDEFINITE RECORD
    @indefinite_key -- date_key
  , @indefinite_text -- day_desc_01
  , @indefinite_text -- day_desc_02
  , @indefinite_text -- day_desc_03
  , @indefinite_text -- day_desc_04
  , @indefinite_text -- weekday_desc_01
  , @indefinite_text -- weekday_desc_02

  , @indefinite_key -- week_key
  , @indefinite_text -- week_desc_01
  , @indefinite_text -- week_desc_02
  , @indefinite_text -- week_desc_03
  , @indefinite_text -- week_desc_04

  , @indefinite_key_6digit -- month_key
  , @indefinite_text -- month_desc_01
  , @indefinite_text -- month_desc_02
  , @indefinite_text -- month_desc_03
  , @indefinite_text -- month_desc_04
  , @indefinite_text -- month_of_year_desc_01
  , @indefinite_text -- month_of_year_desc_02

  , @indefinite_key_6digit -- quarter_key
  , @indefinite_text -- quarter_desc_01
  , @indefinite_text -- quarter_desc_02
  , @indefinite_text -- quarter_desc_03
  , @indefinite_text -- quarter_desc_04
  , @indefinite_text -- quarter_of_year_desc_01
  , @indefinite_text -- quarter_of_year_desc_02

  , @indefinite_key_4digit -- year_key
  , @indefinite_text -- year_desc_01
  , @indefinite_text -- year_desc_02  
  
  , @source_key -- source_key
  , @source_revision_actor -- source_revision_actor
  , CURRENT_TIMESTAMP -- source_revision_dtm

  , @unknown_key -- init_process_batch_key
  , @unknown_key -- process_batch_key
  )

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- determine the start date, end date and source key
  -- NOTE: expanding range by one year from start and end...should be cleaned up at end

  set @current_dt = CONVERT(date,CAST(@begin_year-1 as CHAR(4)) + '-01-01')
  set @last_dt = CONVERT(date,CAST(@end_year+1 as CHAR(4)) + '-12-31')
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- loop and load basic values into calendar table

  CREATE TABLE #cal (
    date_key int
  , [date] date
  , day_of_week int
  , weekday_ind int
  , holiday_ind int
  , workday_ind int
  , week_key int
  , month_key int
  , month_of_quarter int
  , month_of_year int
  , quarter_key int
  , quarter_of_year int
  , year_key int
  , [year] int
  );
    
  WHILE @current_dt <= @last_dt
  BEGIN

    SET @current_date_key = CAST(CONVERT(char(8), @current_dt, 112) AS INT);
    SET @current_day_of_week = DATEPART(weekday,@current_dt)

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- determine if the date is a weekend
    IF @current_day_of_week IN (1,7)
      SET @current_weekend_ind = 1   
    ELSE
      SET @current_weekend_ind = 0
    ;

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- determine if the date is a holiday
    IF EXISTS (SELECT 1 FROM dbo.calendar_holiday ch WHERE ch.holiday_date_key = @current_date_key)
      SET @current_holiday_ind = 1    
    ELSE
      SET @current_holiday_ind = 0
    ;


    INSERT INTO #cal (
      date_key
    , [date]
    , day_of_week
    , weekday_ind
    , holiday_ind
    , workday_ind
    , week_key
    , month_key
    , month_of_quarter
    , month_of_year
    , quarter_key
    , quarter_of_year
    , year_key
    , [year]
    ) 
    VALUES (
      @current_date_key -- date_key
    , @current_dt -- [date]
    , @current_day_of_week
    , CASE WHEN @current_weekend_ind = 0 THEN 1 ELSE 0 END -- weekday_ind
    , @current_holiday_ind -- holiday_ind
    , CASE WHEN @current_weekend_ind = 1 OR @current_holiday_ind = 1 THEN 0 ELSE 1 END -- workday_ind
    , CONVERT(char(8),DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt),112) -- week_key
    , YEAR(@current_dt)*100 + MONTH(@current_dt) -- month_key
    , CASE
	    WHEN MONTH(@current_dt) >= 10 THEN 4 
	    WHEN MONTH(@current_dt) >= 7 THEN 3
	    WHEN MONTH(@current_dt) >= 4 THEN 2
	    ELSE 1 END -- month_of_quarter
    , MONTH(@current_dt) -- month_of_year
    , YEAR(@current_dt)*100 +
      CASE
	    WHEN MONTH(@current_dt) >= 10 THEN 4 
	    WHEN MONTH(@current_dt) >= 7 THEN 3
	    WHEN MONTH(@current_dt) >= 4 THEN 2
	    ELSE 1 END -- quarter_key
    , CASE
	    WHEN MONTH(@current_dt) >= 10 THEN 4 
	    WHEN MONTH(@current_dt) >= 7 THEN 3
	    WHEN MONTH(@current_dt) >= 4 THEN 2
	    ELSE 1 END -- quarter_of_year
    , YEAR(@current_dt) -- year_key
    , YEAR(@current_dt) -- year
    );

    SET @current_dt = DATEADD(d,1,@current_dt)

  END

  INSERT INTO calendar (
    date_key
  , [date]
  , day_of_week
  , day_of_month
  , day_of_quarter
  , day_of_year
  , day_desc_01
  , day_desc_02
  , day_desc_03
  , day_desc_04
  , weekday_desc_01
  , weekday_desc_02
  , day_weekdays
  , day_workdays

  , week_key
  , week_begin_dt
  , week_end_dt
  , week_desc_01
  , week_desc_02
  , week_desc_03
  , week_desc_04
  , week_days
  , week_weekdays
  , week_workdays

  , month_key
  , month_begin_dt
  , month_end_dt
  , month_of_quarter
  , month_of_year
  , month_desc_01
  , month_desc_02
  , month_desc_03
  , month_desc_04
  , month_of_year_desc_01
  , month_of_year_desc_02
  , month_days
  , month_weekdays
  , month_workdays

  , quarter_key
  , quarter_begin_dt
  , quarter_end_dt
  , quarter_of_year
  , quarter_desc_01
  , quarter_desc_02
  , quarter_desc_03
  , quarter_desc_04
  , quarter_of_year_desc_01
  , quarter_of_year_desc_02
  , quarter_days
  , quarter_weekdays
  , quarter_workdays
  , quarter_months

  , year_key
  , [year]
  , year_begin_dt
  , year_end_dt
  , year_desc_01
  , year_desc_02
  , year_days
  , year_weekdays
  , year_workdays
  , year_months
  , year_quarters

  , source_key
  , source_revision_actor
  , source_revision_dtm

  , init_process_batch_key
  , process_batch_key

  )
  SELECT

    /* DATE LEVEL */

    c.date_key-- date_key
  , c.[date] -- date
  , c.day_of_week -- day_of_week
  , ROW_NUMBER() OVER (PARTITION BY c.month_key ORDER BY c.date_key) -- day_of_month
  , ROW_NUMBER() OVER (PARTITION BY c.quarter_key ORDER BY c.date_key) -- day_of_quarter
  , ROW_NUMBER() OVER (PARTITION BY c.year_key ORDER BY c.date_key) -- day_of_year
  , FORMAT(c.[date], 'MM/dd/yyyy') -- day_desc_01
  , FORMAT(c.[date], 'dd-MMM-yyyy') -- day_desc_02
  , FORMAT(c.[date], 'yyyy-MM-dd') -- day_desc_03
  , FORMAT(c.[date], 'MMMM d, yyyy') -- day_desc_04
  , SUBSTRING(DATENAME(weekday,c.[date]),1,3) -- weekday_desc_01
  , DATENAME(weekday,c.[date]) -- weekday_desc_02
  , c.weekday_ind -- day_weekdays
  , c.workday_ind -- day_workdays

    /* WEEK LEVEL */

  , c.week_key -- week_key
  , MIN(c.[date]) OVER (PARTITION BY c.week_key) -- week_begin_dt
  , MAX(c.[date]) OVER (PARTITION BY c.week_key)  -- week_end_dt
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.week_key), 'MM/dd/yyyy') -- week_desc_01
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.week_key), 'MMM-dd') -- week_desc_02
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.week_key), 'MMMM d, yyyy') -- week_desc_03
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.week_key), 'MMM-dd') + ' To '
      + FORMAT(MAX(c.[date]) OVER (PARTITION BY c.week_key), 'MMM-dd') -- week_desc_04
  , 7 -- week_days
  , SUM(c.weekday_ind) OVER (PARTITION BY c.week_key) -- week_weekdays
  , SUM(c.workday_ind) OVER (PARTITION BY c.week_key) -- week_workdays


    /* MONTH LEVEL */

  , c.month_key -- month_key
  , MIN(c.[date]) OVER (PARTITION BY c.month_key) -- month_begin_dt
  , MAX(c.[date]) OVER (PARTITION BY c.month_key) -- month_end_dt
  , c.month_of_quarter -- month_of_quarter
  , c.month_of_year -- month_of_year
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.month_key), 'MMM-yyyy') -- month_desc_01
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.month_key), 'MMMM yyyy') -- month_desc_02
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.month_key), 'yyyy-MMM') -- month_desc_03
  , 'Reserved' -- month_desc_04
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.month_key), 'MMMM') -- month_of_year_desc_01
  , FORMAT(MIN(c.[date]) OVER (PARTITION BY c.month_key), 'MMM') -- month_of_year_desc_02
  , SUM(1) OVER (PARTITION BY c.month_key) -- month_days
  , SUM(c.weekday_ind) OVER (PARTITION BY c.month_key) -- month_weekdays
  , SUM(c.workday_ind) OVER (PARTITION BY c.month_key) -- month_workdays
      
    /* QUARTER LEVEL */
      
  , c.quarter_key -- quarter_key
  , MIN(c.[date]) OVER (PARTITION BY c.quarter_key) -- quarter_begin_dt
  , MAX(c.[date]) OVER (PARTITION BY c.quarter_key) -- quarter_end_dt
  , c.quarter_of_year -- quarter_of_year
  , 'Q' + CAST(c.quarter_of_year AS CHAR(1)) + '-' + CAST(c.[year] AS CHAR(4)) -- quarter_desc_01
  , CAST(c.[year] AS CHAR(4)) + '-Q' + CAST(c.quarter_of_year AS CHAR(1)) -- quarter_desc_02
  , 'Quarter ' + CAST(c.quarter_of_year AS CHAR(1)) + ', ' + CAST(c.[year] AS CHAR(4))  -- quarter_desc_03
  , 'Reserved' -- quarter_desc_04
  , 'Q' + CAST(c.quarter_of_year AS CHAR(1)) -- quarter_of_year_desc_01
  , 'Quarter ' + CAST(c.quarter_of_year AS CHAR(1)) -- quarter_of_year_desc_02
  , SUM(1) OVER (PARTITION BY c.quarter_key) -- quarter_days
  , SUM(c.weekday_ind) OVER (PARTITION BY c.quarter_key) -- quarter_weekdays
  , SUM(c.workday_ind) OVER (PARTITION BY c.quarter_key) -- quarter_workdays
  , 3 -- quarter_months

    /* YEAR LEVEL */

  , c.year_key -- year_key
  , c.[year] -- [year]
  , MIN(c.[date]) OVER (PARTITION BY c.year_key) -- year_begin_dt
  , MAX(c.[date]) OVER (PARTITION BY c.year_key) -- year_end_dt
  , FORMAT(c.[year], '#') -- year_desc_01
  , 'Reserved' -- year_desc_02
  , SUM(1) OVER (PARTITION BY c.year_key) -- year_days
  , SUM(c.weekday_ind) OVER (PARTITION BY c.year_key) -- year_weekdays
  , SUM(c.workday_ind) OVER (PARTITION BY c.year_key) -- year_workdays
  , 12 -- year_months
  , 4 -- year_quarters
      
    /* OTHER */

  , @source_key -- source_key
  , 'SYSTEM' -- source_revision_actor
  , CURRENT_TIMESTAMP -- source_revision_dtm

  , @unknown_key -- init_process_batch_key
  , @unknown_key -- process_batch_key

  FROM
  #cal c
  ;

  -- delete the extra years added to support calculations
  DELETE dc FROM dbo.calendar dc WHERE
  dc.date_key NOT IN (@unknown_key, @indefinite_key)
  AND (
    dc.year < @begin_year
    OR dc.year > @end_year
  );


END
