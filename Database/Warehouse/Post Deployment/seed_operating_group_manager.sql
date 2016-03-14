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
  WHERE x.parent_object_id=OBJECT_ID('dbo.operating_group_manager') AND x.name='operating_group_manager_fk_resource'
)
  ALTER TABLE dbo.operating_group_manager WITH NOCHECK
  ADD CONSTRAINT operating_group_manager_fk_client 
  FOREIGN KEY (manager_resource_key) REFERENCES dbo.resource (resource_key);

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.operating_group_manager') AND x.name='operating_group_manager_fk_operating_group'
)
  ALTER TABLE dbo.operating_group_manager WITH NOCHECK
  ADD CONSTRAINT operating_group_manager_fk_operating_group 
  FOREIGN KEY (operating_group_key) REFERENCES dbo.operating_group (operating_group_key);

END