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

SET IDENTITY_INSERT map.resource ON;

INSERT INTO map.resource (
  resource_key
, source_key
, resource_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as resource_key
, @dw_source_key AS source_key
, @unk_uid as resource_uid
, @process_batch_key as process_batch_key
UNION ALL
SELECT
  @na_key as resource_key
, @dw_source_key AS source_key
, @na_uid as resource_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.resource t WHERE t.resource_key = x.resource_key
);

SET IDENTITY_INSERT map.resource OFF;

/*
#######################################################################
Insert Content Records
#######################################################################
*/

INSERT INTO dbo.resource (
  resource_key
, resource_type_key
, operating_group_key
, full_name
, full_name_collated
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key AS resource_key
, @unk_key AS resource_type_key
, @unk_key AS operating_group_key
, @unk_desc AS full_name
, @unk_desc AS full_name_collated
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  @na_key AS resource_key
, @na_key AS resource_type_key
, @na_key AS operating_group_key
, @na_desc AS full_name
, @na_desc AS full_name_collated
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.resource t WHERE t.resource_key = x.resource_key
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
  WHERE x.parent_object_id=OBJECT_ID('dbo.resource') AND x.name='resource_fk_resource_type'
)
  ALTER TABLE dbo.resource WITH NOCHECK
  ADD CONSTRAINT resource_fk_resource_type 
  FOREIGN KEY (resource_type_key) REFERENCES dbo.resource_type (resource_type_key);


END