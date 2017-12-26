/*
##################################################################
Note that the Fiscal Period keys are smart keys of the form YYYYMM.

Smart keys  are generally forbidden in the architecture, however
we use them for Dates and Fiscal Periods due to their consistently
understood meaning and presumed zero of risk that values may
come from anywhere other than our manual control.  
##################################################################
*/

CREATE TABLE [dbo].[legal_entity_fiscal_period]
(
  -- smart key computed "YYYYPP"
  fiscal_period_key AS
    CONVERT(int, fiscal_year * 100 + fiscal_period_of_year)

  -- GRAIN COLUMN(S)
, legal_entity_uid VARCHAR(200) NOT NULL
, fiscal_period_uid VARCHAR(200) NOT NULL

, fiscal_year int NOT NULL
, fiscal_period_of_year int NOT NULL
, fiscal_period_begin_dt date NOT NULL

  -- Fiscal Period End Date not required
, fiscal_period_end_dt date NULL
, display_month_desc VARCHAR(200) NOT NULL
, fiscal_period_closed_ind bit NOT NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT sbo_fiscal_period_pk PRIMARY KEY CLUSTERED (fiscal_period_uid ASC, legal_entity_uid ASC)
)
;
GO
