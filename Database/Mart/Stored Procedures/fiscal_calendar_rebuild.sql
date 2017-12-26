/* ################################################################################

OBJECT: dbo.fiscal_calendar_rebuild

DESCRIPTION: Truncates and rebuilds the fiscal period table based on a source FP table.

PARAMETERS: None.
  
RETURN VALUE: None.
  
RETURN DATASET: None.

HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2016-03-15  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE [dbo].[fiscal_calendar_rebuild] AS
BEGIN

  SET NOCOUNT ON

  declare
    @source_key int = 0
  , @source_revision_actor varchar(20) = 'SYSTEM'
  , @unknown_key int = 0
  ;
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- completely clear out the calendar table
  
  TRUNCATE TABLE dbo.fiscal_calendar;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- calculate fiscal period end dates
  
  --drop table #fpd
  SELECT
    fp.fiscal_period_key
  , fp.fiscal_period_of_year
  , CAST(fp.fiscal_period_closed_ind AS INT) AS fiscal_period_closed_ind
  , cm.[date] AS fiscal_period_display_dt

  , CASE
    WHEN fp.fiscal_period_of_year IN (1,2,3) THEN 1
    WHEN fp.fiscal_period_of_year IN (4,5,6) THEN 2
    WHEN fp.fiscal_period_of_year IN (7,8,9) THEN 3
    WHEN fp.fiscal_period_of_year IN (10,11,12) THEN 4
    ELSE 4 END AS fiscal_quarter_of_year

  , fp.begin_dt AS fiscal_period_begin_dt
  , ISNULL(DATEADD(day,-1,
      LEAD(fp.begin_dt,1) OVER (PARTITION BY 1 ORDER BY fp.begin_dt)
    ), fp.end_dt) AS fiscal_period_end_dt

  , CASE
    WHEN fp.fiscal_period_of_year IN (1,4,7,10) THEN 1
    WHEN fp.fiscal_period_of_year IN (2,5,8,11) THEN 2
    WHEN fp.fiscal_period_of_year IN (3,6,9,12) THEN 3
    ELSE 3 END AS fiscal_period_of_quarter

  , fp.fiscal_year*100 + 
    CASE
    WHEN fp.fiscal_period_of_year IN (1,2,3) THEN 1
    WHEN fp.fiscal_period_of_year IN (4,5,6) THEN 2
    WHEN fp.fiscal_period_of_year IN (7,8,9) THEN 3
    WHEN fp.fiscal_period_of_year IN (10,11,12) THEN 4
    ELSE 4 END AS fiscal_quarter_key

  , fp.fiscal_year AS fiscal_year_key
  , fp.fiscal_year
  INTO
    #fpd
  FROM
  fiscal_period fp
  LEFT JOIN dbo.calendar cm ON
    cm.day_of_month = 1
    AND cm.year = fp.fiscal_year
    AND cm.month_of_year = fp.display_month_of_year
  ;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- calculate fiscal week begin and end dates

  -- drop table #fwk
  SELECT
    fp.fiscal_period_key
  , c.date_key AS fiscal_week_key
  , c.[date] AS fiscal_week_begin_dt
  , CASE
    WHEN DATEADD(day, 6, c.[date]) > fp.fiscal_period_end_dt THEN fp.fiscal_period_end_dt
    ELSE DATEADD(day, 6, c.[date]) END AS fiscal_week_end_dt
  , ROW_NUMBER() OVER (PARTITION BY fp.fiscal_period_key ORDER BY c.date_key) AS fiscal_week_of_period
  INTO
    #fwk
  FROM
  dbo.calendar c
  INNER JOIN #fpd fp ON
    c.[date] BETWEEN fp.fiscal_period_begin_dt AND fp.fiscal_period_end_dt
  WHERE
  c.day_of_week = DATEPART(WEEKDAY, fp.fiscal_period_begin_dt)
  ;


  INSERT INTO dbo.fiscal_calendar (
    date_key
  , fiscal_day_of_week
  , fiscal_day_of_period
  , fiscal_day_of_quarter
  , fiscal_day_of_year

  , fiscal_week_key
  , fiscal_week_begin_dt
  , fiscal_week_end_dt
  , fiscal_week_desc_01
  , fiscal_week_desc_02
  , fiscal_week_desc_03
  , fiscal_week_desc_04
  , fiscal_week_days
  , fiscal_week_weekdays
  , fiscal_week_workdays
  
  , fiscal_period_key
  , fiscal_period_begin_dt
  , fiscal_period_end_dt
  , fiscal_period_of_quarter
  , fiscal_period_of_year
  , fiscal_period_desc_01
  , fiscal_period_desc_02
  , fiscal_period_desc_03
  , fiscal_period_desc_04
  , fiscal_period_of_year_desc_01
  , fiscal_period_of_year_desc_02
  , fiscal_period_closed_ind
  , fiscal_period_days
  , fiscal_period_weekdays
  , fiscal_period_workdays
  
  , fiscal_quarter_key
  , fiscal_quarter_begin_dt
  , fiscal_quarter_end_dt
  , fiscal_quarter_of_year
  , fiscal_quarter_desc_01
  , fiscal_quarter_desc_02
  , fiscal_quarter_desc_03
  , fiscal_quarter_desc_04
  , fiscal_quarter_of_year_desc_01
  , fiscal_quarter_of_year_desc_02
  , fiscal_quarter_periods
  , fiscal_quarter_days
  , fiscal_quarter_weekdays
  , fiscal_quarter_workdays

  , fiscal_year_key
  , fiscal_year
  , fiscal_year_begin_dt
  , fiscal_year_end_dt
  , fiscal_year_desc_01
  , fiscal_year_desc_02
  , fiscal_year_periods
  , fiscal_year_quarters
  , fiscal_year_days
  , fiscal_year_weekdays
  , fiscal_year_workdays
  , fiscal_year_closed_ind

  , fiscal_week_index
  , fiscal_period_index
  , fiscal_quarter_index
  , fiscal_year_index

  , source_key
  , source_revision_actor
  , source_revision_dtm

  , init_process_batch_key
  , process_batch_key
  )
  SELECT

    /* DATE LEVEL */

    c.date_key
  , ROW_NUMBER() OVER (PARTITION BY fw.fiscal_week_key ORDER BY c.date_key) -- fiscal_day_of_week
  , ROW_NUMBER() OVER (PARTITION BY fp.fiscal_period_key ORDER BY c.date_key) -- fiscal_day_of_period
  , ROW_NUMBER() OVER (PARTITION BY fp.fiscal_quarter_key ORDER BY c.date_key) -- fiscal_day_of_quarter
  , ROW_NUMBER() OVER (PARTITION BY fp.fiscal_year_key ORDER BY c.date_key) -- fiscal_day_of_year

  /* FISCAL WEEK LEVEL */

  , fw.fiscal_week_key -- fiscal_week_key
  , fw.fiscal_week_begin_dt -- fiscal_week_begin_dt
  , fw.fiscal_week_end_dt -- fiscal_week_end_dt
  , FORMAT(fw.fiscal_week_begin_dt, 'MM/dd/yyyy') -- fiscal_week_desc_01
  , FORMAT(fw.fiscal_week_begin_dt, 'MMM-dd')  -- fiscal_week_desc_02
  , FORMAT(fw.fiscal_week_begin_dt, 'MMM-dd')  -- fiscal_week_desc_03
  , FORMAT(fw.fiscal_week_begin_dt, 'MMM-dd') + ' To '
      + FORMAT(fw.fiscal_week_end_dt, 'MMM-dd') -- fiscal_week_desc_04
  , SUM(1) OVER (PARTITION BY fw.fiscal_week_key) -- fiscal_week_days
  , SUM(c.day_weekdays) OVER (PARTITION BY fw.fiscal_week_key) -- fiscal_week_weekdays
  , SUM(c.day_workdays) OVER (PARTITION BY fw.fiscal_week_key) -- fiscal_week_workdays
  
  /* FISCAL PERIOD LEVEL */

  , fp.fiscal_period_key -- fiscal_period_key
  , fp.fiscal_period_begin_dt -- fiscal_period_begin_dt
  , fp.fiscal_period_end_dt -- fiscal_period_end_dt
  , fp.fiscal_period_of_quarter -- fiscal_period_of_quarter
  , fp.fiscal_period_of_year -- fiscal_period_of_year
  , FORMAT(fp.fiscal_period_display_dt, 'MMM yyyy') -- fiscal_period_desc_01
  , FORMAT(fp.fiscal_period_display_dt, 'MMMM yyyy') -- fiscal_period_desc_02
  , 'Reserved' -- fiscal_period_desc_03
  , 'Reserved' -- fiscal_period_desc_04
  , FORMAT(fp.fiscal_period_display_dt, 'MMM') -- fiscal_period_of_year_desc_01
  , FORMAT(fp.fiscal_period_display_dt, 'MMMM') -- fiscal_period_of_year_desc_02
  , fp.fiscal_period_closed_ind -- fiscal_period_closed_ind
  , SUM(1) OVER (PARTITION BY fp.fiscal_period_key) -- fiscal_period_days
  , SUM(c.day_weekdays) OVER (PARTITION BY fp.fiscal_period_key) -- fiscal_period_weekdays
  , SUM(c.day_workdays) OVER (PARTITION BY fp.fiscal_period_key) -- fiscal_period_workdays
  
  /* FISCAL QUARTER LEVEL */

  , fp.fiscal_quarter_key -- fiscal_quarter_key
  , MIN(c.[date]) OVER (PARTITION BY fp.fiscal_quarter_key) -- fiscal_quarter_begin_dt
  , MAX(c.[date]) OVER (PARTITION BY fp.fiscal_quarter_key) -- fiscal_quarter_end_dt
  , fp.fiscal_quarter_of_year -- fiscal_quarter_of_year

  , 'Q' + CAST(fp.fiscal_quarter_of_year AS CHAR(1)) + '-'
      + CAST(fp.fiscal_year AS CHAR(4)) -- fiscal_quarter_desc_01

  , CAST(fp.fiscal_year AS CHAR(4)) + '-Q' + CAST(fp.fiscal_quarter_of_year AS CHAR(1)) -- fiscal_quarter_desc_02
  , 'Quarter ' + CAST(fp.fiscal_quarter_of_year AS CHAR(1)) + ', '
      + CAST(fp.fiscal_year AS CHAR(4)) -- fiscal_quarter_desc_03
  , 'Reserved' -- fiscal_quarter_desc_04
  , 'Q' + CAST(fp.fiscal_quarter_of_year AS CHAR(1)) -- fiscal_quarter_of_year_desc_01
  , 'Quarter ' + CAST(fp.fiscal_quarter_of_year AS CHAR(1)) -- fiscal_quarter_of_year_desc_02

  , (
      SELECT COUNT(DISTINCT x.fiscal_quarter_key)
      FROM #fpd x WHERE x.fiscal_year_key = fp.fiscal_year_key
    ) -- fiscal_quarter_periods
  
  , SUM(1) OVER (PARTITION BY fp.fiscal_quarter_key) -- fiscal_quarter_days
  , SUM(c.day_weekdays) OVER (PARTITION BY fp.fiscal_quarter_key) -- fiscal_quarter_weekdays
  , SUM(c.day_workdays) OVER (PARTITION BY fp.fiscal_quarter_key) -- fiscal_quarter_workdays

  /* FISCAL YEAR LEVEL */

  , fp.fiscal_year_key -- fiscal_year_key
  , fp.fiscal_year -- fiscal_year
  , MIN(c.[date]) OVER (PARTITION BY fp.fiscal_year_key) -- fiscal_year_begin_dt
  , MAX(c.[date]) OVER (PARTITION BY fp.fiscal_year_key) -- fiscal_year_end_dt
  , CAST(fp.fiscal_period_of_year AS CHAR(4)) -- fiscal_year_desc_01
  , 'Reserved' -- fiscal_year_desc_02

  , (
      SELECT COUNT(DISTINCT x.fiscal_quarter_key)
      FROM #fpd x WHERE x.fiscal_year_key = fp.fiscal_year_key
    ) -- fiscal_year_quarters

  , (
      SELECT COUNT(DISTINCT x.fiscal_period_key)
      FROM #fpd x WHERE x.fiscal_year_key = fp.fiscal_year_key
    ) -- fiscal_year_periods

  , SUM(1) OVER (PARTITION BY fp.fiscal_year_key) -- fiscal_year_days
  , SUM(c.day_weekdays) OVER (PARTITION BY fp.fiscal_year_key) -- fiscal_year_weekdays
  , SUM(c.day_weekdays) OVER (PARTITION BY fp.fiscal_year_key) -- fiscal_year_workdays
  , MIN(fp.fiscal_period_closed_ind) OVER (PARTITION BY fp.fiscal_year_key) AS fiscal_year_closed_ind -- fiscal_year_closed_ind

  /* FISCAL CALENDAR INDICES */

  , NULL -- fiscal_week_index
  , NULL -- fiscal_period_index
  , NULL -- fiscal_quarter_index
  , NULL -- fiscal_year_index

  /* OTHER */ 

  , @source_key -- source_key
  , 'SYSTEM' -- source_revision_actor
  , CURRENT_TIMESTAMP -- source_revision_dtm

  , @unknown_key -- init_process_batch_key
  , @unknown_key -- process_batch_key

  FROM
  dbo.calendar c
  INNER JOIN #fpd fp ON c.[date] BETWEEN fp.fiscal_period_begin_dt AND fp.fiscal_period_end_dt
  INNER JOIN #fwk fw ON c.[date] BETWEEN fw.fiscal_week_begin_dt AND fw.fiscal_week_end_dt
  ;


END
