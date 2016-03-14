CREATE PROCEDURE cube.prepare_ops_operating_group_plan AS
BEGIN

SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
SET ANSI_NULLS OFF;

TRUNCATE TABLE cube.ops_operating_group_plan;

INSERT INTO cube.ops_operating_group_plan (
  operating_group_key
, date_key
, project_key
, client_key
, resource_key
, resource_operating_group_key 
, base_plan_revenue_amt 
, base_plan_operating_profit_amt 
, base_plan_gross_profit_amt
)
SELECT
  x.operating_group_key
, x.date_key
, -1 AS project_key
, -1 AS client_key
, -1 AS resource_key
, -1 AS resource_operating_group_key

, NULLIF(CASE WHEN workday_index = 1 THEN

    x.plan_revenue_amt + base_plan_revenue_amt
    - SUM(x.base_plan_revenue_amt) OVER (PARTITION BY x.operating_group_key, x.month_key)

  ELSE x.base_plan_revenue_amt END, 0) AS base_plan_revenue_amt

, NULLIF(CASE WHEN workday_index = 1 THEN
    x.plan_operating_profit_amt + x.base_plan_operating_profit_amt
    - SUM(x.base_plan_operating_profit_amt) OVER (PARTITION BY x.operating_group_key, x.month_key)
  ELSE x.base_plan_operating_profit_amt END, 0) AS base_plan_operating_profit_amt

, NULLIF(CASE WHEN workday_index = 1 THEN
    x.plan_gross_profit_amt + base_plan_gross_profit_amt
    - SUM(x.base_plan_gross_profit_amt) OVER (PARTITION BY x.operating_group_key, x.month_key)
  ELSE x.base_plan_gross_profit_amt END, 0) AS base_plan_gross_profit_amt

FROM
(

  SELECT
    p.operating_group_key
  , c.date_key
  , p.month_key
  , p.plan_revenue_amt
  , p.plan_operating_profit_amt
  , p.plan_gross_profit_amt

  , ROW_NUMBER() OVER (PARTITION BY p.operating_group_key, p.month_key ORDER BY c.date_key DESC) AS workday_index

  , ROUND(
      plan_revenue_amt
      / COUNT(1) OVER (PARTITION BY p.operating_group_key, p.month_key)
    , -1) AS base_plan_revenue_amt

  , ROUND(
      plan_operating_profit_amt
      / COUNT(1) OVER (PARTITION BY p.operating_group_key, p.month_key)
    , -1) AS base_plan_operating_profit_amt


  , ROUND(
      plan_gross_profit_amt
      / COUNT(1) OVER (PARTITION BY p.operating_group_key, p.month_key)
    , -1) AS base_plan_gross_profit_amt

  FROM
  dbo.operating_group_plan p
  INNER JOIN dbo.calendar c ON
    c.month_key = p.month_key 
    AND c.utility_hours > 0

) x

;
END