

CREATE VIEW [cube].[ops_project_stage] AS
SELECT [project_stage_key]
, [project_stage_desc] AS [Project Stage]
, CASE WHEN ps.[project_stage_desc] = 'Won' THEN 'Won'
	WHEN ps.[project_stage_desc] IN ('Identified', 'Contacted') THEN 'Identified'
	WHEN ps.[project_stage_desc] IN ('Proposed', 'Qualified', 'Finalized') THEN 'In-Progress'
	WHEN ps.[project_stage_desc] = 'Lost' THEN 'Lost' ELSE 'Not Applicable'
	END AS [Project Stage Overview]
, sort_order
FROM
[dbo].[project_stage] ps
;