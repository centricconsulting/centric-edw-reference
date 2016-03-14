CREATE VIEW [cube].[ops_resource_type] AS
SELECT [resource_type_key]
, [resource_type_desc] AS [Resource Type]
, [resource_type_code] AS [Resource Type Code]
, CASE
  WHEN [employee_flag] = 'Y' THEN 'Employee' 
  WHEN  [employee_flag] = 'N' THEN 'Non-Employee' 
  ELSE resource_type_desc END AS [Employee Flag]
FROM
[dbo].[resource_type]