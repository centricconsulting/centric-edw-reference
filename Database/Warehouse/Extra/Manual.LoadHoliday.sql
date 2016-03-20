

TRUNCATE TABLE dbo.calendar_holiday;

INSERT INTO dbo.calendar_holiday (
   [holiday_date_key]
  ,[holiday_desc]
  ,[source_key]
  ,[source_revision_actor]
  ,[source_revision_dtm]
  ,[init_process_batch_key]
  ,[process_batch_key]
)
SELECT
  CAST(CONVERT(CHAR(8), HolidayDate, 112) AS INT) AS date_key
, HolidayDesc
, @gov_source_key
, 'SYSTEM'
, CURRENT_TIMESTAMP
, @unknown_key
, @unknown_key
FROM
staging_misc.dbo.Holiday
;