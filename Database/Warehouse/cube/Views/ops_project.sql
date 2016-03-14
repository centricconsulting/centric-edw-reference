



CREATE VIEW [cube].[ops_project] AS
SELECT [project_key]
, [client_key]
, [current_project_stage_key]
, [project_type_key]
, [project_desc] AS Project
, CASE WHEN [internal_flag] = 'Y' THEN 'Internal' ELSE 'External' END AS [Internal Flag]
FROM
dbo.project p 
INNER JOIN dbo.project_stage ps 
ON (p.[current_project_stage_key] = ps.[project_stage_key])
;