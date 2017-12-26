
CREATE PROCEDURE dbo.calendar_index_refresh
  @current_dt date
AS
BEGIN

  SET NOCOUNT ON

  DECLARE
    @unknown_key int = 0
  , @indefinite_key int = 99999999

  /* 
  ###############################################################
  YEAR INDEX
  ###############################################################
  */

  SELECT 
    year_key
  , ROW_NUMBER() OVER (ORDER BY year_key) AS year_basis
  , CASE
    WHEN @current_dt BETWEEN year_begin_dt AND year_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_year
  FROM
  calendar
  WHERE
  day_of_year = 1
  OR date_key IN (@unknown_key, @indefinite_key)
  ;

  UPDATE c
  SET c.year_index = (b.year_basis - bc.year_basis)
  FROM
  calendar c
  INNER JOIN #tmp_year b ON b.year_key = c.year_key
  LEFT JOIN #tmp_year bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (@unknown_key, @indefinite_key)
  ;


  /* 
  ###############################################################
  QUARTER INDEX
  ###############################################################
  */

  SELECT 
    quarter_key
  , ROW_NUMBER() OVER (ORDER BY quarter_key) AS quarter_basis
  , CASE
    WHEN @current_dt BETWEEN quarter_begin_dt AND quarter_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_quarter
  FROM
  calendar c
  WHERE
  day_of_quarter = 1
  OR date_key IN (@unknown_key, @indefinite_key)
  ;

  UPDATE c
  SET c.quarter_index = (b.quarter_basis - bc.quarter_basis)
  FROM
  calendar c
  INNER JOIN #tmp_quarter b ON b.quarter_key = c.quarter_key
  LEFT JOIN #tmp_quarter bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (@unknown_key, @indefinite_key)
  ;

  /* 
  ###############################################################
  MONTH INDEX
  ###############################################################
  */

  SELECT 
    month_key
  , ROW_NUMBER() OVER (ORDER BY month_key) AS month_basis
  , CASE
    WHEN @current_dt BETWEEN month_begin_dt AND month_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_month
  FROM
  calendar c
  WHERE
  day_of_month = 1
  OR date_key IN (@unknown_key, @indefinite_key)
  ;

  UPDATE c
  SET c.month_index = (b.month_basis - bc.month_basis)
  FROM
  calendar c
  INNER JOIN #tmp_month b ON b.month_key = c.month_key
  LEFT JOIN #tmp_month bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (@unknown_key, @indefinite_key)
  ;

  /* 
  ###############################################################
  WEEK INDEX
  ###############################################################
  */

  SELECT 
    week_key
  , ROW_NUMBER() OVER (ORDER BY week_key) AS week_basis
  , CASE
    WHEN @current_dt BETWEEN week_begin_dt AND week_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_week
  FROM
  calendar c
  WHERE
  c.day_of_week = 1
  -- must manually include the first non-zero date key because
  -- the first day of week is not necessarily (1)
  OR c.date_key = (SELECT MIN(cx.date_key) FROM calendar cx WHERE cx.date_key != 0)
  OR c.date_key IN (@unknown_key, @indefinite_key)
  ;

  UPDATE c
  SET c.week_index = (b.week_basis - bc.week_basis)
  FROM
  calendar c
  INNER JOIN #tmp_week b ON b.week_key = c.week_key
  LEFT JOIN #tmp_week bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (@unknown_key, @indefinite_key)
  ;

  /* 
  ###############################################################
  DAY INDEX
  ###############################################################
  */

  SELECT 
    date_key
  , ROW_NUMBER() OVER (ORDER BY date_key) AS date_basis
  , CASE
    WHEN @current_dt = c.[date] THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_date
  FROM
  calendar c
  WHERE
  date_key NOT IN (@unknown_key, @indefinite_key)
  ;

  UPDATE c
  SET c.day_index = (b.date_basis - bc.date_basis)
  FROM
  calendar c
  INNER JOIN #tmp_date b ON b.date_key = c.date_key
  LEFT JOIN #tmp_date bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (@unknown_key, @indefinite_key)
  ;
  

END
