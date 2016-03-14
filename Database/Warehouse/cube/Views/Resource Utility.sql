CREATE VIEW cube.[Resource Utility] AS
SELECT
  r.resource_key
, c.date_key
FROM
dbo.[resource] r

INNER JOIN dbo.resource_type rt ON 
  rt.resource_type_key = r.resource_type_key

INNER JOIN dbo.calendar c ON
  c.[date] BETWEEN r.effective_begin_dt AND r.effective_end_dt
WHERE
c.utility_hours > 0
AND rt.resource_type_code = 'FTE'
-- only include prior, current and next year
AND c.year_index BETWEEN -1 AND 1