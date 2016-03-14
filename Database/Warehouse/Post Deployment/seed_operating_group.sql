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
Insert Map Records - Default Values
#######################################################################
*/

SET IDENTITY_INSERT map.operating_group ON;

INSERT INTO map.operating_group (
  operating_group_key
, source_key
, operating_group_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as operating_group_key
, @dw_source_key AS source_key
, @unk_uid as operating_group_uid
, @process_batch_key as process_batch_key
UNION ALL
SELECT
  @na_key as operating_group_key
, @dw_source_key AS source_key
, @na_uid as operating_group_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.operating_group t WHERE t.operating_group_key = x.operating_group_key
);

SET IDENTITY_INSERT map.operating_group OFF;



/*
#######################################################################
Insert Content Records  - Default Content
#######################################################################
*/

INSERT INTO dbo.operating_group (
  operating_group_key
, operating_group_type_key
, operating_group_desc
, operating_group_code
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT
  x.operating_group_key
, x.operating_group_type_key
, x.operating_group_desc
, x.operating_group_code
, @gov_source_key
, CURRENT_TIMESTAMP source_revision_dtm
, 'SYSTEM' source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key
FROM (

SELECT
  @unk_key AS operating_group_key
, @unk_key AS operating_group_type_key
, @unk_desc AS operating_group_desc
, @unk_uid AS operating_group_code
UNION ALL
SELECT
  @na_key AS operating_group_key
, @na_key AS operating_group_type_key
, @na_desc AS operating_group_desc
, @na_uid AS operating_group_code

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.operating_group t WHERE t.operating_group_key = x.operating_group_key
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
  WHERE x.parent_object_id=OBJECT_ID('dbo.operating_group') AND x.name='operating_group_fk_og_type'
)
  ALTER TABLE dbo.operating_group WITH NOCHECK
  ADD CONSTRAINT operating_group_fk_og_type
  FOREIGN KEY (operating_group_type_key) REFERENCES dbo.operating_group_type (operating_group_type_key);

END