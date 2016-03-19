CREATE TABLE [dbo].[calendar_holiday]
(
  holiday_date_key int NOT NULL
, holiday_desc varchar(100) NOT NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT [dbo_calendar_holiday_pk] PRIMARY KEY (holiday_date_key)

)
