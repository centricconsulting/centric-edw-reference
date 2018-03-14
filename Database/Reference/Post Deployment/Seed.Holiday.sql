﻿/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

INSERT INTO dbo.Holiday (
  HolidayDate
, HolidayDesc
)

SELECT
  x.HolidayDate
, x.HolidayDesc
FROM
( 

  -- SAMPLE US HOLIDAYS
  SELECT
    '2012-01-02' AS HolidayDate
  , 'New Year Day - 2012' AS HolidayDesc
  UNION ALL SELECT '2012-01-16','Martin Luther King Jr. Day - 2012'
  UNION ALL SELECT '2012-02-20','Presidents Day (Washingtons Birthday) - 2012'
  UNION ALL SELECT '2012-05-28','Memorial Day - 2012'
  UNION ALL SELECT '2012-07-04','Independence Day - 2012'
  UNION ALL SELECT '2012-09-03','Labor Day - 2012'
  UNION ALL SELECT '2012-10-08','Columbus Day - 2012'
  UNION ALL SELECT '2012-11-12','Veterans Day - 2012'
  UNION ALL SELECT '2012-11-22','Thanksgiving Day - 2012'
  UNION ALL SELECT '2012-12-25','Christmas Day - 2012'
  UNION ALL SELECT '2013-01-01','New Year Day - 2013'
  UNION ALL SELECT '2013-01-21','Martin Luther King Jr. Day - 2013'
  UNION ALL SELECT '2013-02-18','Presidents Day (Washingtons Birthday) - 2013'
  UNION ALL SELECT '2013-05-27','Memorial Day - 2013'
  UNION ALL SELECT '2013-07-04','Independence Day - 2013'
  UNION ALL SELECT '2013-09-02','Labor Day - 2013'
  UNION ALL SELECT '2013-10-14','Columbus Day - 2013'
  UNION ALL SELECT '2013-11-11','Veterans Day - 2013'
  UNION ALL SELECT '2013-11-28','Thanksgiving Day - 2013'
  UNION ALL SELECT '2013-12-25','Christmas Day - 2013'
  UNION ALL SELECT '2014-01-01','New Year Day - 2014'
  UNION ALL SELECT '2014-01-20','Martin Luther King Jr. Day - 2014'
  UNION ALL SELECT '2014-02-17','Presidents Day (Washingtons Birthday) - 2014'
  UNION ALL SELECT '2014-05-26','Memorial Day - 2014'
  UNION ALL SELECT '2014-07-04','Independence Day - 2014'
  UNION ALL SELECT '2014-09-01','Labor Day - 2014'
  UNION ALL SELECT '2014-10-13','Columbus Day - 2014'
  UNION ALL SELECT '2014-11-11','Veterans Day - 2014'
  UNION ALL SELECT '2014-11-27','Thanksgiving Day - 2014'
  UNION ALL SELECT '2014-12-25','Christmas Day - 2014'
  UNION ALL SELECT '2015-01-01','New Year Day - 2015'
  UNION ALL SELECT '2015-01-19','Martin Luther King Jr. Day - 2015'
  UNION ALL SELECT '2015-02-16','Presidents Day (Washingtons Birthday) - 2015'
  UNION ALL SELECT '2015-05-25','Memorial Day - 2015'
  UNION ALL SELECT '2015-07-03','Independence Day - 2015'
  UNION ALL SELECT '2015-09-07','Labor Day - 2015'
  UNION ALL SELECT '2015-10-12','Columbus Day - 2015'
  UNION ALL SELECT '2015-11-11','Veterans Day - 2015'
  UNION ALL SELECT '2015-11-26','Thanksgiving Day - 2015'
  UNION ALL SELECT '2015-12-25','Christmas Day - 2015'
  UNION ALL SELECT '2016-01-01','New Year Day - 2016'
  UNION ALL SELECT '2016-01-18','Martin Luther King Jr. Day - 2016'
  UNION ALL SELECT '2016-02-15','Presidents Day (Washingtons Birthday) - 2016'
  UNION ALL SELECT '2016-05-30','Memorial Day - 2016'
  UNION ALL SELECT '2016-07-04','Independence Day - 2016'
  UNION ALL SELECT '2016-09-05','Labor Day - 2016'
  UNION ALL SELECT '2016-10-10','Columbus Day - 2016'
  UNION ALL SELECT '2016-11-11','Veterans Day - 2016'
  UNION ALL SELECT '2016-11-24','Thanksgiving Day - 2016'
  UNION ALL SELECT '2016-12-25','Christmas Day - 2016'
  UNION ALL SELECT '2017-01-02','New Year Day - 2017'
  UNION ALL SELECT '2017-01-16','Martin Luther King Jr. Day - 2017'
  UNION ALL SELECT '2017-02-20','Presidents Day (Washingtons Birthday) - 2017'
  UNION ALL SELECT '2017-05-29','Memorial Day - 2017'
  UNION ALL SELECT '2017-07-04','Independence Day - 2017'
  UNION ALL SELECT '2017-09-04','Labor Day - 2017'
  UNION ALL SELECT '2017-10-09','Columbus Day - 2017'
  UNION ALL SELECT '2017-11-10','Veterans Day - 2017'
  UNION ALL SELECT '2017-11-23','Thanksgiving Day - 2017'
  UNION ALL SELECT '2017-12-25','Christmas Day - 2017'
  UNION ALL SELECT '2018-01-01','New Year Day - 2018'
  UNION ALL SELECT '2018-01-15','Martin Luther King Jr. Day - 2018'
  UNION ALL SELECT '2018-02-19','Presidents Day (Washingtons Birthday) - 2018'
  UNION ALL SELECT '2018-05-28','Memorial Day - 2018'
  UNION ALL SELECT '2018-07-04','Independence Day - 2018'
  UNION ALL SELECT '2018-09-03','Labor Day - 2018'
  UNION ALL SELECT '2018-10-08','Columbus Day - 2018'
  UNION ALL SELECT '2018-11-12','Veterans Day - 2018'
  UNION ALL SELECT '2018-11-22','Thanksgiving Day - 2018'
  UNION ALL SELECT '2018-12-25','Christmas Day - 2018'
  UNION ALL SELECT '2019-01-01','New Year Day - 2019'
  UNION ALL SELECT '2019-01-21','Martin Luther King Jr. Day - 2019'
  UNION ALL SELECT '2019-02-18','Presidents Day (Washingtons Birthday) - 2019'
  UNION ALL SELECT '2019-05-27','Memorial Day - 2019'
  UNION ALL SELECT '2019-07-04','Independence Day - 2019'
  UNION ALL SELECT '2019-09-02','Labor Day - 2019'
  UNION ALL SELECT '2019-10-14','Columbus Day - 2019'
  UNION ALL SELECT '2019-11-11','Veterans Day - 2019'
  UNION ALL SELECT '2019-11-28','Thanksgiving Day - 2019'
  UNION ALL SELECT '2019-12-25','Christmas Day - 2019'
  UNION ALL SELECT '2020-01-01','New Year Day - 2020'
  UNION ALL SELECT '2020-01-20','Martin Luther King Jr. Day - 2020'
  UNION ALL SELECT '2020-02-17','Presidents Day (Washingtons Birthday) - 2020'
  UNION ALL SELECT '2020-05-25','Memorial Day - 2020'
  UNION ALL SELECT '2020-07-03','Independence Day - 2020'
  UNION ALL SELECT '2020-09-07','Labor Day - 2020'
  UNION ALL SELECT '2020-10-12','Columbus Day - 2020'
  UNION ALL SELECT '2020-11-11','Veterans Day - 2020'
  UNION ALL SELECT '2020-11-26','Thanksgiving Day - 2020'
  UNION ALL SELECT '2020-12-25','Christmas Day - 2020'


) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.Holiday h WHERE h.HolidayDate = x.HolidayDate
);