



CREATE VIEW [cube].[ops_calendar] AS
SELECT
  date_key
, utility_hours
, [date]
, day_desc_01 AS [Day]
, day_of_week
, date_index
, weekday_desc_01 AS [Weekday]
, week_key
, week_desc_01 AS [Week]
, month_key
, month_desc_01 AS [Month]
, month_of_year
, month_desc_04 AS [Month Of Year]
, month_index
, closed_month_index
, quarter_key
, quarter_desc_01 AS [Quarter]
, quarter_of_year
, quarter_desc_02 AS [Quarter Of Year]
, quarter_index
, closed_quarter_index
, year_key
, year_desc_01 AS [Year]
, year_index
, closed_year_index
, CASE WHEN closed_month_index BETWEEN -2 AND 0 THEN 'Last 3 Months'
	WHEN closed_month_index <= -3 THEN '4+ Months Ago'
	WHEN closed_month_index BETWEEN 1 AND 3 THEN 'Next 3 Months'
	WHEN closed_month_index >=4 THEN '4+ Months Ahead' END AS [Closed 3Mo Filter]

, CASE WHEN closed_month_index BETWEEN -11 AND 0 THEN 'Last 12 Months'
	WHEN closed_month_index <= -12 THEN '13+ Months Ago'
	WHEN closed_month_index BETWEEN 1 AND 12 THEN 'Next 12 Months'
	WHEN closed_month_index >=13 THEN '12+ Months Ahead' END AS [Closed 12Mo Filter] 

, CASE WHEN closed_month_index BETWEEN -5 AND 0 THEN 'Last 6 Months'
	WHEN closed_month_index <= -6 THEN '7+ Months Ago'
	WHEN closed_month_index BETWEEN 1 AND 6 THEN 'Next 6 Months'
	WHEN closed_month_index >=7 THEN '7+ Months Ahead' END AS [Closed 6Mo Filter]

, CASE WHEN closed_year_index = 0 THEN 'Last Closed Year'
	WHEN closed_year_index = -1 THEN '2Yr Ago Closed Year'
	WHEN closed_year_index = -2 THEN '3Yr Ago Closed Year'
	WHEN closed_year_index = -3 THEN '4Yr Ago Closed Year'
	WHEN closed_year_index = -4 THEN '5Yr Ago Closed Year'
	WHEN closed_year_index = 1 THEN 'Current Open Year'
	WHEN closed_year_index <= -5 THEN 'Not Applicable'
	WHEN closed_year_index >= 2 THEN 'Not Applicable' END AS [Closed Year Filter]

, CASE WHEN	closed_month_index = 0 THEN 'Last Closed Month'
	WHEN closed_month_index = 1 THEN 'Current Open Month'
	WHEN closed_month_index = -1 THEN '1Mo Ago Closed Month'
	WHEN closed_month_index = 2 THEN '1Mo Open Ahead' END AS [Closed Month Filter]

, CASE WHEN	closed_quarter_index = 0 THEN 'Last Closed Quarter'
	WHEN closed_quarter_index = 1 THEN 'Current Open Quarter'
	WHEN closed_quarter_index = -1 THEN '1Qa Ago Closed Quarter'
	WHEN closed_quarter_index = 2 THEN '1Qa Open Ahead' END AS [Closed Quarter Filter]
FROM
dbo.calendar c
WHERE
1=1
OR c.date_key = 0
OR c.date_key = 99999999
;