

CREATE PROCEDURE [dbo].[calendar_closed_index_refresh] @closed_dt DATE
AS 
BEGIN

-- update month index
  SELECT 
    month_key
  , row_number() OVER (ORDER BY month_key) AS month_basis
  , CASE
    WHEN @closed_dt BETWEEN month_start_dt AND month_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_closed_month
  FROM
  calendar c
  WHERE
  day_of_month = 1
  OR date_key IN (0,99999999)
  ;

  UPDATE c
  SET c.closed_month_index = (b.month_basis - bc.month_basis)
  FROM
  calendar c
  INNER JOIN #tmp_closed_month b ON b.month_key = c.month_key
  LEFT JOIN #tmp_closed_month bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (0,99999999)
  ;


  -- update quarter index
  SELECT 
    quarter_key
  , row_number() OVER (ORDER BY quarter_key) AS quarter_basis
  , CASE
    WHEN @closed_dt BETWEEN quarter_start_dt AND quarter_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_closed_quarter
  FROM
  calendar c
  WHERE
  day_of_quarter = 1
  OR date_key IN (0,99999999)
  ;

  UPDATE c
  SET c.closed_quarter_index = (b.quarter_basis - bc.quarter_basis)
  FROM
  calendar c
  INNER JOIN #tmp_closed_quarter b ON b.quarter_key = c.quarter_key
  LEFT JOIN #tmp_closed_quarter bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (0,99999999)
  ;

  -- update year index
  SELECT 
    year_key
  , row_number() OVER (ORDER BY year_key) AS year_basis
  , CASE
    WHEN @closed_dt BETWEEN year_start_dt AND year_end_dt THEN 1 
    ELSE 0 END AS current_ind
  INTO #tmp_closed_year
  FROM
  calendar
  WHERE
  day_of_year = 1
  OR date_key IN (0,99999999)
  ;

  UPDATE c
  SET c.closed_year_index = (b.year_basis - bc.year_basis + 1)
  FROM
  calendar c
  INNER JOIN #tmp_closed_year b ON b.year_key = c.year_key
  LEFT JOIN #tmp_closed_year bc ON bc.current_ind = 1
  WHERE
  c.date_key NOT IN (0,99999999)
  ;

END