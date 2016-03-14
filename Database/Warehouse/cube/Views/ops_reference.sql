CREATE VIEW cube.[ops_reference] AS

SELECT
  cu.date_key AS current_date_key
, cs.start_date_key AS last_closed_month_start_date_key
, cs.end_date_key AS last_closed_month_end_date_key
, CURRENT_TIMESTAMP AS [Refresh Datetime]
, cu.[date] AS [Current Date]
, cu.[Month] AS [Current Month]
, cs.[Month] AS [Last Closed Month]
FROM
(
  
  SELECT TOP 1
    date_key
  , [date]
  , month_desc_02 AS [Month]
  FROM
  dbo.calendar c
  WHERE
  date_index = 0

) cu
CROSS JOIN (

  SELECT
    MAX(date_key) AS start_date_key
  , MIN(date_key) AS end_date_key 
  , MAX(month_desc_02) AS [Month]
  FROM
  dbo.calendar c
  WHERE
  closed_month_index = 0

) cs
;