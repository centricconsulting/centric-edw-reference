CREATE PROCEDURE fiscal_calendar_rebuild
  @start_year int = 2000
, @end_year int = 2030
, @fiscal_period_month_shift int = 1
AS
BEGIN

  SET NOCOUNT ON

  declare
    @source_key int
  , @current_dt date
  , @last_dt date
  , @date_uid char(8)
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- completely clear out the calendar table
  
  TRUNCATE TABLE dbo.calendar;

  declare
    @unknown_text varchar(20) = 'Unknown'
  , @unknown_key int = 0
  , @indefinite_text varchar(20) = 'Indefinite'
  , @indefinite_key int = 0
  ;

  INSERT INTO calendar (
    date_key
  , weekday_desc_01
  , weekday_desc_02
  , month_desc_01
  , month_desc_02
  , month_desc_03
  , month_desc_04
  , quarter_desc_01
  , quarter_desc_02
  , quarter_desc_03
  , quarter_desc_04
  , year_desc_01
  , fiscal_period_desc_01
  , fiscal_period_desc_02
  , fiscal_period_desc_03
  , fiscal_period_desc_04
  , fiscal_quarter_desc_01
  , fiscal_quarter_desc_02
  , fiscal_quarter_desc_03
  , fiscal_quarter_desc_04
  , fiscal_year_desc_01
  , week_key
  , month_key
  , quarter_key
  , year_key
  , fiscal_period_key
  , fiscal_quarter_key
  , fiscal_year_key
  , batch_key
  ) VALUES (
    @unknown_key -- date_key
  , @unknown_text -- weekday_desc_01
  , @unknown_text -- weekday_desc_02
  , @unknown_text -- month_desc_01
  , @unknown_text -- month_desc_02
  , @unknown_text -- month_desc_03
  , @unknown_text -- month_desc_04
  , @unknown_text -- quarter_desc_01
  , @unknown_text -- quarter_desc_02
  , @unknown_text -- quarter_desc_03
  , @unknown_text -- quarter_desc_04
  , @unknown_text -- year_desc_01
  , @unknown_text -- fiscal_period_desc_01
  , @unknown_text -- fiscal_period_desc_02
  , @unknown_text -- fiscal_period_desc_03
  , @unknown_text -- fiscal_period_desc_04
  , @unknown_text -- fiscal_quarter_desc_01
  , @unknown_text -- fiscal_quarter_desc_02
  , @unknown_text -- fiscal_quarter_desc_03
  , @unknown_text -- fiscal_quarter_desc_04
  , @unknown_text -- fiscal_year_desc_@unknown_key1
  , @unknown_key -- week_key
  , @unknown_key -- month_key
  , @unknown_key -- quarter_key
  , @unknown_key -- year_key
  , @unknown_key -- fiscal_period_key
  , @unknown_key -- fiscal_quarter_key
  , @unknown_key -- fiscal_year_key
  , @unknown_key -- batch_key
  )
  ,  (
    @indefinite_key -- date_key
  , @indefinite_text -- weekday_desc_01
  , @indefinite_text -- weekday_desc_02
  , @indefinite_text -- month_desc_01
  , @indefinite_text -- month_desc_02
  , @indefinite_text -- month_desc_03
  , @indefinite_text -- month_desc_04
  , @indefinite_text -- quarter_desc_01
  , @indefinite_text -- quarter_desc_02
  , @indefinite_text -- quarter_desc_03
  , @indefinite_text -- quarter_desc_04
  , @indefinite_text -- year_desc_01
  , @indefinite_text -- fiscal_period_desc_01
  , @indefinite_text -- fiscal_period_desc_02
  , @indefinite_text -- fiscal_period_desc_03
  , @indefinite_text -- fiscal_period_desc_04
  , @indefinite_text -- fiscal_quarter_desc_01
  , @indefinite_text -- fiscal_quarter_desc_02
  , @indefinite_text -- fiscal_quarter_desc_03
  , @indefinite_text -- fiscal_quarter_desc_04
  , @indefinite_text -- fiscal_year_desc_01
  , @indefinite_key -- week_key
  , @indefinite_key -- month_key
  , @indefinite_key -- quarter_key
  , @indefinite_key -- year_key
  , @indefinite_key -- fiscal_period_key
  , @indefinite_key -- fiscal_quarter_key
  , @indefinite_key -- fiscal_year_key
  , 0 -- batch_key
  )

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- determine the start date, end date and source key
  -- NOTE: expanding range by one year from start and end...should be cleaned up at end

  set @current_dt = CONVERT(date,CAST(@start_year-1 as CHAR(4)) + '-01-01')
  set @last_dt = CONVERT(date,CAST(@end_year+1 as CHAR(4)) + '-12-31')
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- loop and load basic values into calendar table
    
  WHILE @current_dt <= @last_dt
  BEGIN

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
    , week_key
    , week_start_dt
    , week_end_dt
    , week_days
    , week_weekdays
    , month_key
    , month_start_dt
    , month_end_dt
    , month_of_quarter
    , month_of_year
    , month_desc_01
    , month_desc_02
    , month_desc_03
    , month_desc_04
    , month_days
    , month_weekdays
    , quarter_key
    , quarter_start_dt
    , quarter_end_dt
    , quarter_of_year
    , quarter_desc_01
    , quarter_desc_02
    , quarter_desc_03
    , quarter_desc_04
    , quarter_months
    , quarter_days
    , quarter_weekdays
    , year_key
    , [year]
    , year_start_dt
    , year_end_dt
    , year_desc_01
    , year_months
    , year_quarters
    , year_days
    , year_weekdays
    , batch_key
    ) VALUES (
      CAST(CONVERT(char(8), @current_dt, 112) AS INT) -- date_key
    , @source_key -- source_key
    , @current_dt -- date
    , DATEPART(weekday,@current_dt) -- day_of_week
    , DATEPART(day,@current_dt) -- day_of_month
    , NULL -- day_of_quarter
    , DATEPART(dayofyear,@current_dt) -- day_of_year
    , CONVERT(char(10),@current_dt,101) -- day_desc_01 "12/31/2010"
    , SUBSTRING(@date_uid,7,2) + '-' + SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + SUBSTRING(@date_uid,1,4) -- day_desc_02 "31-Dec-2010"
    , SUBSTRING(@date_uid,1,4) + '.' + SUBSTRING(@date_uid,5,2) + '.' + SUBSTRING(@date_uid,7,2) -- day_desc_03 "2010.12.31"   
    , DATENAME(month,@current_dt) + ' ' + CAST(DAY(@current_dt) as varchar(2)) + ', ' + CAST(YEAR(@current_dt) as varchar(4)) -- day_desc_04 "December 31, 2010"
    , SUBSTRING(DATENAME(weekday,@current_dt),1,3) -- weekday_desc_01 "Wed"    
    , DATENAME(weekday,@current_dt) -- weekday_desc_02 "Wednesday"
    , CASE WHEN DATEPART(weekday,@current_dt) IN (1,7) THEN 0 ELSE 1 END -- day_weekdays
    , CONVERT(char(8),DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt),112) -- week_key
    , DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt) -- week_start_dt
    , DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt) -- week_end_dt
    , 7 -- week_days
    , 5 -- week_weekdays
    , YEAR(@current_dt)*100 + MONTH(@current_dt) -- month_key
    , NULL -- month_start_dt
    , NULL -- month_end_dt
    , CONVERT(int,(MONTH(@current_dt)-1)/3) + 1 -- month_of_quarter
    , MONTH(@current_dt) -- month_of_year
    , SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + CAST(YEAR(@current_dt) as varchar(4)) -- month_desc_01
    , DATENAME(month,@current_dt) + ' ' + CAST(YEAR(@current_dt) as varchar(4)) -- month_desc_02
    , SUBSTRING(DATENAME(month,@current_dt),1,3) -- month_desc_03
    , DATENAME(month,@current_dt) -- month_desc_04
    , NULL -- month_days
    , NULL -- month_weekdays
    , YEAR(@current_dt)*100
	    + CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 4 
	      WHEN MONTH(@current_dt) >= 7 THEN 3
	      WHEN MONTH(@current_dt) >= 4 THEN 2
	      ELSE 1 END -- quarter_key
    , NULL -- quarter_start_dt
    , NULL -- quarter_end_dt
    ,  CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 4 
	      WHEN MONTH(@current_dt) >= 7 THEN 3
	      WHEN MONTH(@current_dt) >= 4 THEN 2
	      ELSE 1 END -- quarter_of_year
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 'Q4' 
	      WHEN MONTH(@current_dt) >= 7 THEN 'Q3'
	      WHEN MONTH(@current_dt) >= 4 THEN 'Q2'
	      ELSE 'Q1' END + '.' + CAST(YEAR(@current_dt) as varchar(4)) -- quarter_desc_01
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 'Q4' 
	      WHEN MONTH(@current_dt) >= 7 THEN 'Q3'
	      WHEN MONTH(@current_dt) >= 4 THEN 'Q2'
	      ELSE 'Q1' END -- quarter_desc_02
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN '4th' 
	      WHEN MONTH(@current_dt) >= 7 THEN '3rd'
	      WHEN MONTH(@current_dt) >= 4 THEN '2nd'
	      ELSE '1st' END   + ' Quarter, ' + CAST(YEAR(@current_dt) as varchar(4))-- quarter_desc_03
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN '4th' 
	      WHEN MONTH(@current_dt) >= 7 THEN '3rd'
	      WHEN MONTH(@current_dt) >= 4 THEN '2nd'
	      ELSE '1st' END   + ' Quarter' -- quarter_desc_04
    , 3 -- quarter_months
    , NULL -- quarter_days
    , NULL -- quarter_weekdays
    , YEAR(@current_dt)  -- year_key
    , YEAR(@current_dt)  -- year  
    , NULL -- year_start_dt
    , NULL -- year_end_dt
    , CAST(YEAR(@current_dt) as varchar(4)) -- year_desc_01
    , 12 -- year_months
    , 4 -- year_quarters
    , NULL -- year_days
    , NULL -- year_weekdays
    , 0 -- batch_key        
    );
        
    SET @current_dt = DATEADD(d,1,@current_dt)
    
  END
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- update standard calendar counts and positions

  update cal set
    month_days = x.month_days
  , month_weekdays = x.month_weekdays
  , month_start_dt = x.month_start_dt
  , month_end_dt = x.month_end_dt
  , day_of_quarter = x.day_of_quarter
  , quarter_days = x.quarter_days
  , quarter_weekdays = x.quarter_weekdays
  , quarter_start_dt = x.quarter_start_dt
  , quarter_end_dt = x.quarter_end_dt  
  , year_days = x.year_days
  , year_weekdays = x.year_weekdays
  , year_start_dt = x.year_start_dt
  , year_end_dt = x.year_end_dt
  FROM
  calendar cal
  inner join (
  
    select
      date_key

    , COUNT(date_key) OVER (partition by month_key) as month_days
    , COUNT(CASE WHEN day_weekdays = 1 THEN date_key END) OVER (partition by month_key) as month_weekdays
    , MIN([date]) over (partition by month_key) as month_start_dt
    , MAX([date]) over (partition by month_key) as month_end_dt  
    
    , ROW_NUMBER() over (partition by quarter_key order by date_key) as day_of_quarter
    , COUNT(date_key) OVER (partition by quarter_key) as quarter_days
    , COUNT(CASE WHEN day_weekdays = 1 THEN date_key END) OVER (partition by quarter_key) as quarter_weekdays  
    , MIN([date]) over (partition by quarter_key) as quarter_start_dt
    , MAX([date]) over (partition by quarter_key) as quarter_end_dt
      
    , COUNT(date_key) OVER (partition by year_key) as year_days
    , COUNT(CASE WHEN day_weekdays = 1 THEN date_key END) OVER (partition by year_key) as year_weekdays
    , MIN([date]) over (partition by year_key) as year_start_dt
    , MAX([date]) over (partition by year_key) as year_end_dt
    
    from
    calendar
    
  ) x on x.date_key = cal.date_key
  WHERE
  cal.date_key NOT IN (0,99999999);
  

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- update fiscal calendar based on fiscal period month shift
  
  update cal set
    fiscal_period_key = x.month_key
  , fiscal_period_of_quarter = x.month_of_quarter
  , fiscal_period_of_year = x.month_of_year
  , fiscal_period_desc_01 = 'FP' + CASE WHEN x.month_of_year < 10 THEN '0' else '' end + CAST(x.month_of_year as varchar(2)) + '.' + CAST(x.YEAR as varchar(4))
  , fiscal_period_desc_02 = 'FP' + CASE WHEN x.month_of_year < 10 THEN '0' else '' end + CAST(x.month_of_year as varchar(2))
  , fiscal_period_desc_03 = 'Reserved'
  , fiscal_period_desc_04 = 'Reserved'
  , fiscal_quarter_key = x.quarter_key
  , fiscal_quarter_periods = x.quarter_months
  , fiscal_quarter_of_year = x.quarter_of_year
  , fiscal_quarter_desc_01 = replace(x.quarter_desc_01,'Q','FQ')
  , fiscal_quarter_desc_02 = replace(x.quarter_desc_02,'Q','FQ')
  , fiscal_quarter_desc_03 = replace(x.quarter_desc_03,'Quarter','Fiscal Quarter')
  , fiscal_quarter_desc_04 = replace(x.quarter_desc_04,'Quarter','Fiscal Quarter')
  , fiscal_year_key = x.year_key
  , fiscal_year = x.year
  , fiscal_year_desc_01 = 'FY ' + x.year_desc_01
  , fiscal_year_periods = x.year_months
  , fiscal_year_quarters = x.year_quarters 
  FROM
  calendar cal
  inner join calendar x on
    (cal.year*12 + cal.month_of_year - 1) = (x.year*12 + x.month_of_year - 1 + @fiscal_period_month_shift)
  where
  x.day_of_month = 1
  and cal.date_key NOT IN (0,99999999);

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- update fiscal calendar counts and positions

  update cal set
    fiscal_day_of_period = x.fiscal_day_of_period
  , fiscal_day_of_quarter = x.fiscal_day_of_quarter
  , fiscal_day_of_year = x.fiscal_day_of_year
  , fiscal_period_days = x.fiscal_period_days
  , fiscal_period_weekdays = x.fiscal_period_weekdays
  , fiscal_period_start_dt = x.fiscal_period_start_dt
  , fiscal_period_end_dt = x.fiscal_period_end_dt
  , fiscal_quarter_days = x.fiscal_quarter_days
  , fiscal_quarter_weekdays = x.fiscal_quarter_weekdays
  , fiscal_quarter_start_dt = x.fiscal_quarter_start_dt
  , fiscal_quarter_end_dt = x.fiscal_quarter_end_dt  
  , fiscal_year_days = x.fiscal_year_days
  , fiscal_year_weekdays = x.fiscal_year_weekdays
  , fiscal_year_start_dt = x.fiscal_year_start_dt
  , fiscal_year_end_dt = x.fiscal_year_end_dt
  FROM
  calendar cal
  inner join (
  
    select
      date_key
      
    , ROW_NUMBER() over (partition by fiscal_period_key order by date_key) as fiscal_day_of_period
    , ROW_NUMBER() over (partition by fiscal_quarter_key order by date_key) as fiscal_day_of_quarter
    , ROW_NUMBER() over (partition by fiscal_year_key order by date_key) as fiscal_day_of_year

    , COUNT(date_key) OVER (partition by fiscal_period_key) as fiscal_period_days
    , COUNT(CASE WHEN day_weekdays = 1 THEN date_key END) OVER (partition by fiscal_period_key) as fiscal_period_weekdays
    , MIN([date]) over (partition by fiscal_period_key) as fiscal_period_start_dt
    , MAX([date]) over (partition by fiscal_period_key) as fiscal_period_end_dt  
    
    , COUNT(date_key) OVER (partition by fiscal_quarter_key) as fiscal_quarter_days
    , COUNT(CASE WHEN day_weekdays = 1 THEN date_key END) OVER (partition by fiscal_quarter_key) as fiscal_quarter_weekdays  
    , MIN([date]) over (partition by fiscal_quarter_key) as fiscal_quarter_start_dt
    , MAX([date]) over (partition by fiscal_quarter_key) as fiscal_quarter_end_dt
      
    , COUNT(date_key) OVER (partition by fiscal_year_key) as fiscal_year_days
    , COUNT(CASE WHEN day_weekdays = 1 THEN date_key END) OVER (partition by fiscal_year_key) as fiscal_year_weekdays
    , MIN([date]) over (partition by fiscal_year_key) as fiscal_year_start_dt
    , MAX([date]) over (partition by fiscal_year_key) as fiscal_year_end_dt
    
    from
    calendar
    
  ) x on x.date_key = cal.date_key
  WHERE
  cal.date_key NOT IN (0,99999999);  

  
   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- delete extra calendar years expanded earlier
  
  delete from calendar where
  (year < @start_year or year >  @end_year)
  and date_key NOT IN (0,99999999)

END