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
Insert Map Records
#######################################################################
*/

SET IDENTITY_INSERT map.project ON;

INSERT INTO map.project (
  project_key
, source_key
, project_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as project_key
, @dw_source_key AS source_key
, @unk_uid as project_uid
, @process_batch_key as process_batch_key

UNION ALL

SELECT
  @na_key as project_key
, @dw_source_key AS source_key
, @na_uid as project_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.project t WHERE t.project_key = x.project_key
);

SET IDENTITY_INSERT map.project OFF;

/*
#######################################################################
Insert Content Records
#######################################################################
*/

INSERT INTO dbo.project (
  project_key
, client_key
, operating_group_key
, project_type_key
, current_project_stage_key
, project_desc
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key AS project_key
, @unk_key as client_key
, @unk_key as operating_group_key
, @unk_key as project_type_key
, @unk_key as current_project_stage_key
, @unk_desc AS project_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  @na_key AS project_key
, @na_key as client_key
, @na_key as operating_group_key
, @na_key as project_type_key
, @na_key as current_project_stage_key
, @na_desc AS project_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.project t WHERE t.project_key = x.project_key
);

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
  WHERE x.parent_object_id=OBJECT_ID('dbo.project') AND x.name='project_fk_client'
)
  ALTER TABLE dbo.project WITH NOCHECK
  ADD CONSTRAINT project_fk_client 
  FOREIGN KEY (client_key) REFERENCES dbo.client (client_key);

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.project') AND x.name='project_fk_project_type'
)
  ALTER TABLE dbo.project WITH NOCHECK
  ADD CONSTRAINT project_fk_project_type 
  FOREIGN KEY (project_type_key) REFERENCES dbo.project_type (project_type_key);

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.project') AND x.name='project_fk_project_stage'
)
  ALTER TABLE dbo.project WITH NOCHECK
  ADD CONSTRAINT project_fk_project_stage 
  FOREIGN KEY (current_project_stage_key) REFERENCES dbo.project_stage (project_stage_key);

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.project') AND x.name='project_fk_operating_group'
)
  ALTER TABLE dbo.project WITH NOCHECK
  ADD CONSTRAINT project_fk_operating_group 
  FOREIGN KEY (operating_group_key) REFERENCES dbo.operating_group (operating_group_key);

END