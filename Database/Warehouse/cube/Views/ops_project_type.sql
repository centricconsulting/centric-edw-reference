
CREATE VIEW [cube].[ops_project_type]
 AS 
SELECT [project_type_key]
      ,[project_type_desc] AS [Project Type Desc]
      ,[project_type_code] AS [Project Type Code]
      ,CASE WHEN [internal_flag] = 'Y' THEN 'Internal' 
	  WHEN [internal_flag] = 'N' THEN 'External' END AS [internal_flag]
  FROM [dbo].[project_type];