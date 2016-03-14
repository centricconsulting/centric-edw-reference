/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/*
#######################################################################
Add foreign key constraint
#######################################################################
*/

IF @environment != 'production' AND @retain_fk_constraints = 1
BEGIN

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.project_resource_plan') AND x.name='project_resource_plan_fk_resource'
)
  ALTER TABLE dbo.project_resource_plan WITH NOCHECK
  ADD CONSTRAINT project_resource_plan_fk_resource 
  FOREIGN KEY (resource_key) REFERENCES dbo.resource (resource_key);


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.project_resource_plan') AND x.name='project_resource_plan_fk_project'
)
  ALTER TABLE dbo.project_resource_plan WITH NOCHECK
  ADD CONSTRAINT project_resource_plan_fk_project 
  FOREIGN KEY (project_key) REFERENCES dbo.project (project_key);


END