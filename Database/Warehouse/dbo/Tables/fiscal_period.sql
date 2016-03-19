CREATE TABLE [dbo].[fiscal_period]
(
  fiscal_period_key int NOT NULL
, fiscal_year int NOT NULL
, fiscal_period_of_year int NOT NULL
, begin_dt int NOT NULL
, end_dt int NOT NULL
, display_month_of_year int NOT NULL

, source_key int NOT NULL
, source_revision_dtm datetime NOT NULL
, source_revision_actor varchar(50) NULL

, init_audit_process_batch_key  int NOT NULL
, audit__batch_key int NOT NULL

, CONSTRAINT fiscal_period_pk PRIMARY KEY (fiscal_period_key)
)
;
GO

CREATE UNIQUE INDEX fiscal_period_gx ON dbo.fiscal_period (fiscal_year, fiscal_period_of_year)
;
