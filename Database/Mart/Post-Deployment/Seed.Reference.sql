/*          
--------------------------------------------------------------------------------------
Only insert the reference record if it does not exist
Check constraint prevents multiple record inserts
--------------------------------------------------------------------------------------
*/

IF NOT EXISTS (SELECT 1 FROM dbo.reference)
BEGIN

  INSERT INTO [dbo].[reference] (
    [current_year]
  , [current_date]
  , [current_date_key]
  , [current_date_desc]
  , [current_month_key]
  , [current_month_desc]
  , [closed_month_key]
  , [closed_month_desc]
  , [mart_refresh_timestamp]
  , [wwi_refresh_timestamp]
  )
  SELECT
    2000 AS [current_year]
  , '2000-01-01' AS [current_date]
  , 20000101 AS [current_date_key]
  , 'Jan-01-2000' AS[current_date_desc]
  , 20001 AS [current_month_key]
  , 'Jan-2000' AS [current_month_desc]
  , 199911 AS [closed_month_key]
  , 'Nov-1999' AS [closed_month_desc]
  , CURRENT_TIMESTAMP AS [mart_refresh_timestamp]
  , CURRENT_TIMESTAMP AS [wwi_refresh_timestamp]
  ;

END;
