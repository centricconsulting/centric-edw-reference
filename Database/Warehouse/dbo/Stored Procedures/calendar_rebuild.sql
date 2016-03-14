CREATE PROCEDURE calendar_rebuild
  @start_year int = 2010
, @end_year int = 2020
AS
BEGIN

  SET NOCOUNT ON

  declare
    @source_key int
  , @current_dt date
  , @last_dt date
  , @date_uid char(8)
  , @first_of_month_weekday int
  , @current_weekday int
  , @week_of_month int
 
  declare 
	@unknown_key int = 0
  , @unknown_text varchar(20) = 'Unknown'
  , @extreme_key int = 99999999
  , @extreme_text varchar(20) = 'Indefinite'
  , @process_batch_key int = 0;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- completely clear out the calendar table
  
  TRUNCATE TABLE calendar;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert zero key

	INSERT INTO calendar (
	  date_key
    , day_desc_01
	, day_desc_02
	, day_desc_03
	, day_desc_04
	, weekday_desc_01
	, weekday_desc_02
	, week_desc_01
	, week_desc_02
	, week_desc_03
	, month_desc_01
	, month_desc_02
	, month_desc_03
	, month_desc_04
	, quarter_desc_01
	, quarter_desc_02
	, quarter_desc_03
	, quarter_desc_04
	, year_desc_01
	, week_key
	, month_key
	, quarter_key
	, year_key
  , process_batch_key
	) VALUES (
	  @unknown_key -- date_key
	, @unknown_text -- day_desc_01
	, @unknown_text -- day_desc_02
	, @unknown_text -- day_desc_03
	, @unknown_text -- day_desc_04
	, @unknown_text -- weekday_desc_01
	, @unknown_text -- weekday_desc_02
	, @unknown_text -- week_desc_01
	, @unknown_text -- week_desc_02
	, @unknown_text -- week_desc_03
	, @unknown_text -- month_desc_01
	, @unknown_text -- month_desc_02
	, @unknown_text -- month_desc_03
	, @unknown_text -- month_desc_04
	, @unknown_text -- quarter_desc_01
	, @unknown_text -- quarter_desc_02
	, @unknown_text -- quarter_desc_03
	, @unknown_text -- quarter_desc_04
	, @unknown_text -- year_desc_01
	, @unknown_key -- week_key
	, @unknown_key -- month_key
	, @unknown_key -- quarter_key
	, @unknown_key -- year_key
	, @process_batch_key -- process_batch_key
	)

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- determine the start date, end date and source key
  -- NOTE: expanding range by one year from start and end...should be cleaned up at end

  set @current_dt = CONVERT(date,CAST(@start_year-1 as CHAR(4)) + '-01-01')
  set @last_dt = CONVERT(date,CAST(@end_year+1 as CHAR(4)) + '-12-31')
  
  select @source_key = 1 -- x.source_key from source x where x.source_uid = 'STD'

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- loop and load basic values into calendar table
    
  WHILE @current_dt <= @last_dt
  BEGIN

    SET @date_uid = CONVERT(char(8),@current_dt,112)

	SET @first_of_month_weekday = DATEPART(weekday, (DATEFROMPARTS(YEAR(@current_dt), month(@current_dt), 1)));
	SET @week_of_month = FLOOR((DAY(@current_dt) + @first_of_month_weekday - 2) / 7) + 1;

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
    , day_weekday_ct
    , week_key
    , week_start_dt
    , week_end_dt
    , week_day_ct
    , week_weekday_ct
    , week_desc_01
    , week_desc_02
    , week_desc_03
    , month_key
    , month_start_dt
    , month_end_dt
    , month_of_quarter
    , month_of_year
    , month_desc_01
    , month_desc_02
    , month_desc_03
    , month_desc_04
    , month_day_ct
    , month_weekday_ct
    , quarter_key
    , quarter_start_dt
    , quarter_end_dt
    , quarter_of_year
    , quarter_desc_01
    , quarter_desc_02
    , quarter_desc_03
    , quarter_desc_04
    , quarter_month_ct
    , quarter_day_ct
    , quarter_weekday_ct
    , year_key
    , [year]
    , year_start_dt
    , year_end_dt
    , year_desc_01
    , year_month_ct
    , year_quarter_ct
    , year_day_ct
    , year_weekday_ct
    , process_batch_key
    ) VALUES (
      CONVERT(int,@date_uid) -- date_key
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
    , CASE WHEN DATEPART(weekday,@current_dt) IN (1,7) THEN 0 ELSE 1 END -- day_weekday_ct
    , CONVERT(char(8),DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt),112) -- week_key
    , DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt) -- week_start_dt
    , DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt) -- week_end_dt
    , 7 -- week_day_ct
    , 5 -- week_weekday_ct
    , FORMAT(DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt), 'M/d/yyyy') -- week_desc_01
    , FORMAT(DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt), 'M/d/yyyy') -- week_desc_02
    , 'Week ' + FORMAT(DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt), 'M/d') + '-'
      + FORMAT(DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt), 'M/d') --  week_desc_03
    , YEAR(@current_dt)*100 + MONTH(@current_dt) -- month_key
    , NULL -- month_start_dt
    , NULL -- month_end_dt
    , CONVERT(int,(MONTH(@current_dt)-1)/3) + 1 -- month_of_quarter
    , MONTH(@current_dt) -- month_of_year
    , SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + CAST(YEAR(@current_dt) as varchar(4)) -- month_desc_01
    , DATENAME(month,@current_dt) + ' ' + CAST(YEAR(@current_dt) as varchar(4)) -- month_desc_02
    , SUBSTRING(DATENAME(month,@current_dt),1,3) -- month_desc_03
    , DATENAME(month,@current_dt) -- month_desc_04
    , NULL -- month_day_ct
    , NULL -- month_weekday_ct
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
    , 3 -- quarter_month_ct
    , NULL -- quarter_day_ct
    , NULL -- quarter_weekday_ct
    , YEAR(@current_dt)  -- year_key
    , YEAR(@current_dt)  -- year  
    , NULL -- year_start_dt
    , NULL -- year_end_dt
    , CAST(YEAR(@current_dt) as varchar(4)) -- year_desc_01
    , 12 -- year_month_ct
    , 4 -- year_quarter_ct
    , NULL -- year_day_ct
    , NULL -- year_weekday_ct        
    , @process_batch_key -- process_batch_key
    );
        
    SET @current_dt = DATEADD(d,1,@current_dt)
    
  END
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- update standard calendar counts and positions

  update cal set
    month_day_ct = x.month_day_ct
  , month_weekday_ct = x.month_weekday_ct
  , month_start_dt = x.month_start_dt
  , month_end_dt = x.month_end_dt
  , day_of_quarter = x.day_of_quarter
  , quarter_day_ct = x.quarter_day_ct
  , quarter_weekday_ct = x.quarter_weekday_ct
  , quarter_start_dt = x.quarter_start_dt
  , quarter_end_dt = x.quarter_end_dt  
  , year_day_ct = x.year_day_ct
  , year_weekday_ct = x.year_weekday_ct
  , year_start_dt = x.year_start_dt
  , year_end_dt = x.year_end_dt
  FROM
  calendar cal
  inner join (
  
    select
      date_key

    , COUNT(date_key) OVER (partition by month_key) as month_day_ct
    , COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (partition by month_key) as month_weekday_ct
    , MIN([date]) over (partition by month_key) as month_start_dt
    , MAX([date]) over (partition by month_key) as month_end_dt  
    
    , ROW_NUMBER() over (partition by quarter_key order by date_key) as day_of_quarter
    , COUNT(date_key) OVER (partition by quarter_key) as quarter_day_ct
    , COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (partition by quarter_key) as quarter_weekday_ct  
    , MIN([date]) over (partition by quarter_key) as quarter_start_dt
    , MAX([date]) over (partition by quarter_key) as quarter_end_dt
      
    , COUNT(date_key) OVER (partition by year_key) as year_day_ct
    , COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (partition by year_key) as year_weekday_ct
    , MIN([date]) over (partition by year_key) as year_start_dt
    , MAX([date]) over (partition by year_key) as year_end_dt
    
    from
    calendar
    
  ) x on x.date_key = cal.date_key
  WHERE
  cal.date_key != 0;
  

   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- delete extra calendar years expanded earlier
  
  delete from calendar where
  (year = @start_year - 1 or year = @end_year + 1 )
  and date_key != 0;

  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert the extreme date record

  INSERT INTO calendar (
	  date_key
	, day_desc_01
	, day_desc_02
	, day_desc_03
	, day_desc_04
	, weekday_desc_01
	, weekday_desc_02
	, week_desc_01
	, week_desc_02
	, week_desc_03
	, month_desc_01
	, month_desc_02
	, month_desc_03
	, month_desc_04
	, quarter_desc_01
	, quarter_desc_02
	, quarter_desc_03
	, quarter_desc_04
	, year_desc_01
	, week_key
	, month_key
	, quarter_key
	, year_key
  , process_batch_key
	) VALUES (
	  @extreme_key -- date_key
	, @extreme_text -- day_desc_01
	, @extreme_text -- day_desc_02
	, @extreme_text -- day_desc_03
	, @extreme_text -- day_desc_04
	, @extreme_text -- weekday_desc_01
	, @extreme_text -- weekday_desc_02
	, @extreme_text -- week_desc_01
	, @extreme_text -- week_desc_01
	, @extreme_text -- week_desc_01
	, @extreme_text -- month_desc_01
	, @extreme_text -- month_desc_02
	, @extreme_text -- month_desc_03
	, @extreme_text -- month_desc_04
	, @extreme_text -- quarter_desc_01
	, @extreme_text -- quarter_desc_02
	, @extreme_text -- quarter_desc_03
	, @extreme_text -- quarter_desc_04
	, @extreme_text -- year_desc_01
	, @extreme_key -- week_key
	, @extreme_key -- month_key
	, @extreme_key -- quarter_key
	, @extreme_key -- year_key
	, @process_batch_key -- process_batch_key
	)
       
END
