CREATE PROCEDURE [cube].prepare_ops_resource_book AS

SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
SET ANSI_NULLS OFF;

TRUNCATE TABLE cube.ops_resource_book;

INSERT INTO cube.ops_resource_book (
  project_key 
, project_operating_group_key
, client_key
, resource_key 
, resource_operating_group_key 
, book_date_key 
, [Charge Flag] 
, base_book_revenue 
, base_book_hours
)

SELECT
  b.project_key
, p.operating_group_key AS project_operating_group_key
, p.client_key
, b.resource_key
, r.operating_group_key AS resource_operating_group_key
, cu.date_key AS book_date_key
, CASE WHEN b.charge_flag = 'Y' THEN 'Chargeable' ELSE 'Non-Chargeable' END AS [Charge Flag]
, cu.utility_hours * b.bill_rate * b.utilization_rate AS book_revenue
, cu.utility_hours * b.utilization_rate AS book_hours

FROM
dbo.project_resource_book b
INNER JOIN (

  SELECT
    bx.project_resource_book_key
    -- count the weekdays: assumes start/end dates are nominal weeks
--  , SUM(cs.day_weekday_ct) AS workday_ct
  , COUNT(DISTINCT cs.workday_index) AS workday_ct
  , MIN(cs.next_workday_index) AS start_workday_index
  FROM
  dbo.project_resource_book bx
  INNER JOIN dbo.calendar cs ON cs.date_key BETWEEN bx.start_date_key AND bx.end_date_key
  WHERE
  cs.workday_index IS NOT NULL
  GROUP BY
  project_resource_book_key

) be ON be.project_resource_book_key = b.project_resource_book_key

INNER JOIN dbo.calendar cs ON cs.workday_index = be.start_workday_index

INNER JOIN dbo.calendar ce ON ce.workday_index = (be.start_workday_index + be.workday_ct - 1)

INNER JOIN dbo.calendar cu ON 
  cu.date_key BETWEEN cs.date_key AND ce.date_key
  AND cu.utility_hours > 0

INNER JOIN dbo.project p ON p.project_key = b.project_key
INNER JOIN dbo.[resource] r ON r.resource_key = b.resource_key

;