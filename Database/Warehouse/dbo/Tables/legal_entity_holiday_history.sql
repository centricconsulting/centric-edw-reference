CREATE TABLE [dbo].[legal_entity_holiday_history]
(
  legal_entity_holiday_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMN(S)
, legal_entity_uid VARCHAR(200) NOT NULL
, holiday_dt date NOT NULL

, holiday_desc varchar(100) NOT NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT [dbo_legal_entity_holiday_pk] PRIMARY KEY (holiday_dt ASC, legal_entity_uid ASC)

)
