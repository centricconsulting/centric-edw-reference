CREATE PROCEDURE cube.prepare_ops_timesheet AS

SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
SET ANSI_NULLS OFF;

TRUNCATE TABLE cube.ops_timesheet;

INSERT INTO cube.ops_timesheet (
  [project_key] 
, [resource_key] 
, [bill_date_key] 
, [client_key] 
, [operating_group_key]
, [resource_operating_group_key]
, [Charge Flag]
, [base_report_hours] 
, [base_work_hours] 
, [base_nonwork_hours]
, [base_charge_hours] 
, [base_noncharge_hours]
, [base_timesheet_revenue] 
, [base_available_hours]
)

SELECT
  xx.project_key
, xx.resource_key
, xx.bill_date_key
, pxx.client_key
, pxx.operating_group_key
, rxx.operating_group_key AS resource_operating_group_key
, CASE xx.chargeable_flag WHEN 'Y' THEN 'Chargeable' ELSE 'Non-Chargeable' END AS [Chargeable Flag]
, ISNULL(xx.report_hours, 0) AS base_report_hours
, ISNULL(xx.work_hours, 0) AS base_work_hours
, ISNULL(xx.nonwork_hours, 0) AS base_nonwork_hours
, CASE WHEN xx.chargeable_flag = 'Y' THEN ISNULL(xx.report_hours, 0) ELSE 0 END AS base_charge_hours
, CASE WHEN xx.chargeable_flag != 'Y' THEN ISNULL(xx.report_hours, 0) ELSE 0 END AS base_noncharge_hours
, ISNULL(xx.timesheet_revenue, 0) AS base_timesheet_revenue
, xx.available_hours AS base_available_hours

FROM
(

  /*
  ========================================
  WORK HOURS - ASSIGNED ALL UTILITY HOURS
  ========================================
  */

  SELECT
    x.project_key
  , x.resource_key
  , x.bill_date_key
  , x.report_hours
  , CASE x.work_type WHEN 'Work' THEN x.report_hours ELSE NULL END AS work_hours
  , CASE x.work_type WHEN 'Work' THEN NULL ELSE x.report_hours END AS nonwork_hours  
  , x.timesheet_revenue
  , CASE
    -- non-FTEs always have available hours = bill hours
    WHEN x.resource_type_code != 'FTE' THEN x.report_hours
    -- if there is only a single timesheet record on the date, assign it the full utility hours
    WHEN x.intraday_ct = 1 THEN x.utility_hours
    -- if the record index for the day > 1, assign the proportion
    WHEN x.intraday_index > 1 THEN

      x.utility_hours * intraday_ratio

    -- if the record index for the day = 1, assign the balance
    WHEN x.intraday_index = 1 THEN

      x.utility_hours * (
        1.00 - SUM(CASE WHEN x.intraday_index > 1 THEN x.intraday_ratio ELSE 0 END)
          OVER (PARTITION BY x.resource_key, x.bill_date_key)
      )

    END AS available_hours
  , CASE x.work_type WHEN 'Work' THEN x.chargeable_flag ELSE 'N' END AS chargeable_flag
  FROM
  (

    SELECT
      t.project_key
    , t.resource_key
    , t.bill_date_key
    , t.bill_hours AS report_hours
    , t.bill_rate * t.bill_hours AS timesheet_revenue
    , ROW_NUMBER() OVER (PARTITION BY t.resource_key, t.bill_date_key ORDER BY t.bill_hours DESC) AS intraday_index
    , COUNT(1) OVER (PARTITION BY t.resource_key, t.bill_date_key) intraday_ct
  
    , ROUND(t.bill_hours 
      / SUM(t.bill_hours) OVER  (PARTITION BY t.resource_key, t.bill_date_key ORDER BY t.bill_hours DESC) 
      , 2) AS intraday_ratio

    , c.utility_hours
	  , t.chargeable_flag
    , rt.resource_type_code
    , pt.work_type
    FROM
    dbo.timesheet t
    LEFT JOIN dbo.calendar c ON c.date_key = t.bill_date_key
    INNER JOIN dbo.project p ON p.project_key = t.project_key
    INNER JOIN dbo.project_type pt ON pt.project_type_key = p.project_type_key
    INNER JOIN dbo.[resource] r ON r.resource_key = t.resource_key
    INNER JOIN dbo.[resource_type] rt ON rt.resource_type_key = r.resource_type_key
    WHERE
    t.bill_hours != 0

  ) x
    

  /*
  ========================================
  OTHER AVAILABLE HOURS -- ONLY FTE
  ========================================
  */

  UNION ALL

  SELECT
    -1 AS project_key
  , rx.resource_key
  , c.date_key AS bill_date_key
  , 0 AS report_hours
  , 0 as work_hours
  , 0 AS nonwork_hours 
  , 0 AS timesheet_revenue
  , c.utility_hours
  , 'N' AS chargeable_flag
  FROM
  (

    SELECT
     resource_key
    , CAST(CONVERT(CHAR(8),ISNULL(hire_dt, effective_begin_dt),112) AS INT) AS start_date_key
    , ISNULL(CAST(CONVERT(CHAR(8),termination_dt,112) AS INT), max_date_key) AS end_date_key
    FROM
    dbo.resource r
    INNER JOIN dbo.resource_type rt ON rt.resource_type_key = r.resource_type_key
    CROSS JOIN (
      SELECT MAX(date_key) AS max_date_key FROM dbo.calendar WHERE utility_hours > 0
    ) cu
    WHERE
    rt.resource_type_code = 'FTE'

  ) rx
  INNER JOIN dbo.calendar c ON c.date_key BETWEEN rx.start_date_key AND rx.end_date_key
  WHERE
  c.utility_hours > 0
  AND c.year_index <= 1
  AND NOT EXISTS (
    SELECT 1 FROM dbo.timesheet t
    WHERE t.bill_hours > 0
    AND t.resource_key = rx.resource_key
    AND t.bill_date_key = c.date_key
  )

) xx
INNER JOIN dbo.project pxx ON pxx.project_key = xx.project_key
INNER JOIN dbo.resource rxx ON rxx.resource_key = xx.resource_key

;

GO	