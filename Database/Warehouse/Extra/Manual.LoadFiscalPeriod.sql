

TRUNCATE TABLE dbo.fiscal_period;

INSERT INTO dbo.fiscal_period (
[fiscal_period_key]
,[fiscal_year]
,[fiscal_period_of_year]
,[begin_dt]
,[end_dt]
,[display_month_of_year]
,[fiscal_period_closed_ind]
,[source_key]
,[source_revision_dtm]
,[source_revision_actor]
,[init_audit_process_batch_key]
,[process_batch_key]
)
SELECT
  fp.FiscalYear*100 + fp.FiscalPeriodOfYear
, fp.FiscalYear
, fp.FiscalPeriodOfYear
, fp.BeginDate
, fp.EndDate
, fp.DisplayMonthOfYear
, CASE WHEN fp.FiscalPeriodClosedFlag = 'Y' THEN 1 ELSE 0 END 
, @gov_source_key
, CURRENT_TIMESTAMP
, 'SYSTEM'
, @unknown_key
, @unknown_key
FROM
staging_misc.dbo.FiscalPeriod fp
;
