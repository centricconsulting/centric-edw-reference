CREATE PROCEDURE dbo.fiscal_calendar_index_refresh
  @current_dt date
AS
BEGIN

  SET NOCOUNT ON

  /* 
  ###############################################################
  FISCAL YEAR INDEX
  ###############################################################
  */

  SELECT 
    fiscal_year_key
  , ROW_NUMBER() OVER (ORDER BY fiscal_year_key) AS fiscal_year_basis
  , CASE
    WHEN @current_dt BETWEEN fiscal_year_begin_dt AND fiscal_year_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_fiscal_year
  FROM
  dbo.fiscal_calendar
  WHERE
  fiscal_day_of_year = 1
  ;

  UPDATE c
  SET c.fiscal_year_index = (b.fiscal_year_basis - bc.fiscal_year_basis)
  FROM
  dbo.fiscal_calendar c
  INNER JOIN #tmp_fiscal_year b ON b.fiscal_year_key = c.fiscal_year_key
  LEFT JOIN #tmp_fiscal_year bc ON bc.current_ind = 1
  ;

  /* 
  ###############################################################
  CLOSED FISCAL YEAR INDEX
  ###############################################################
  */

  SELECT 
    fiscal_year_key
  , ROW_NUMBER() OVER (ORDER BY fiscal_year_key) AS fiscal_year_basis
  , CASE
    WHEN fiscal_year IN (
     
      -- return the max fiscal year of all those that have all periods closed
      SELECT MAX(xx.fiscal_year) FROM (
        SELECT x.fiscal_year FROM dbo.fiscal_calendar x
        GROUP BY x.fiscal_year HAVING MIN(x.fiscal_year_closed_ind) > 0
      ) xx

    ) THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_closed_fiscal_year
  FROM
  dbo.fiscal_calendar
  WHERE
  fiscal_day_of_year = 1
  ;

  UPDATE c
  SET c.closed_fiscal_year_index = (b.fiscal_year_basis - bc.fiscal_year_basis)
  FROM
  dbo.fiscal_calendar c
  INNER JOIN #tmp_closed_fiscal_year b ON b.fiscal_year_key = c.fiscal_year_key
  LEFT JOIN #tmp_closed_fiscal_year bc ON bc.current_ind = 1
  ;


  /* 
  ###############################################################
  FISCAL QUARTER YEAR INDEX
  ###############################################################
  */

  SELECT 
    fiscal_quarter_key
  , ROW_NUMBER() OVER (ORDER BY fiscal_quarter_key) AS fiscal_quarter_basis
  , CASE
    WHEN @current_dt BETWEEN fiscal_quarter_begin_dt AND fiscal_quarter_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_fiscal_quarter
  FROM
  dbo.fiscal_calendar c
  WHERE
  fiscal_day_of_quarter = 1
  ;

  UPDATE c
  SET c.fiscal_quarter_index = (b.fiscal_quarter_basis - bc.fiscal_quarter_basis)
  FROM
  dbo.fiscal_calendar c
  INNER JOIN #tmp_fiscal_quarter b ON b.fiscal_quarter_key = c.fiscal_quarter_key
  LEFT JOIN #tmp_fiscal_quarter bc ON bc.current_ind = 1
  ;

  /* 
  ###############################################################
  FISCAL PERIOD INDEX
  ###############################################################
  */

  SELECT 
    fiscal_period_key
  , ROW_NUMBER() OVER (ORDER BY fiscal_period_key) AS fiscal_period_basis
  , CASE
    WHEN @current_dt BETWEEN fiscal_period_begin_dt AND fiscal_period_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_fiscal_period
  FROM
  dbo.fiscal_calendar c
  WHERE
  fiscal_day_of_period = 1
  ;

  UPDATE c
  SET c.fiscal_period_index = (b.fiscal_period_basis - bc.fiscal_period_basis)
  FROM
  dbo.fiscal_calendar c
  INNER JOIN #tmp_fiscal_period b ON b.fiscal_period_key = c.fiscal_period_key
  LEFT JOIN #tmp_fiscal_period bc ON bc.current_ind = 1
  ;

  /* 
  ###############################################################
  CLOSED FISCAL PERIOD INDEX
  ###############################################################
  */


  SELECT 
    fiscal_period_key
  , ROW_NUMBER() OVER (ORDER BY fiscal_period_key) AS fiscal_period_basis
  , CASE
    WHEN fiscal_period_key IN (
     
      -- select max fiscal period of all those that are closed
      SELECT MAX(xx.fiscal_period_key) FROM (
        SELECT x.fiscal_period_key FROM dbo.fiscal_calendar x
        GROUP BY x.fiscal_period_key HAVING MIN(x.fiscal_period_closed_ind) > 0
      ) xx

    ) THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_closed_fiscal_period
  FROM
  dbo.fiscal_calendar c
  WHERE
  fiscal_day_of_period = 1
  ;

  UPDATE c
  SET c.closed_fiscal_period_index = (b.fiscal_period_basis - bc.fiscal_period_basis)
  FROM
  dbo.fiscal_calendar c
  INNER JOIN #tmp_closed_fiscal_period b ON b.fiscal_period_key = c.fiscal_period_key
  LEFT JOIN #tmp_closed_fiscal_period bc ON bc.current_ind = 1
  ;

  /* 
  ###############################################################
  FISCAL WEEK INDEX
  ###############################################################
  */

  SELECT 
    fiscal_week_key
  , ROW_NUMBER() OVER (ORDER BY fiscal_week_key) AS fiscal_week_basis
  , CASE
    WHEN @current_dt BETWEEN fiscal_week_begin_dt AND fiscal_week_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_fiscal_week
  FROM
  dbo.fiscal_calendar c
  WHERE
  c.fiscal_day_of_week = 1
  ;

  UPDATE c
  SET c.fiscal_week_index = (b.fiscal_week_basis - bc.fiscal_week_basis)
  FROM
  dbo.fiscal_calendar c
  INNER JOIN #tmp_fiscal_week b ON b.fiscal_week_key = c.fiscal_week_key
  LEFT JOIN #tmp_fiscal_week bc ON bc.current_ind = 1
  ;


END
