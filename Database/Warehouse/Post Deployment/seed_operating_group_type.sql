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

SET IDENTITY_INSERT map.operating_group_type ON;

INSERT INTO map.operating_group_type (
  operating_group_type_key
, source_key
, operating_group_type_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as operating_group_type_key
, @dw_source_key AS source_key
, @unk_uid as operating_group_type_uid
, @process_batch_key as process_batch_key
UNION ALL
SELECT
  @na_key as operating_group_type_key
, @dw_source_key AS source_key
, @na_uid as operating_group_type_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.operating_group_type t WHERE t.operating_group_type_key = x.operating_group_type_key
);

SET IDENTITY_INSERT map.operating_group_type OFF;

/*
#######################################################################
Insert Content Records
#######################################################################
*/

INSERT INTO dbo.operating_group_type (
  operating_group_type_key
, operating_group_type_desc
, operating_group_type_code
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key AS operating_group_type_key
, @unk_desc AS operating_group_type_desc
, @unk_uid AS operating_group_type_code
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  @na_key AS operating_group_type_key
, @na_desc AS operating_group_type_desc
, @na_uid AS operating_group_type_code
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.operating_group_type t WHERE t.operating_group_type_key = x.operating_group_type_key
);




/*
#######################################################################
Insert Map Records - Business Content
#######################################################################
*/


INSERT INTO map.operating_group_type (
  source_key
, operating_group_type_uid
, process_batch_key
)
SELECT 
  @gov_source_key AS source_key
, x.operating_group_type_uid
, @process_batch_key AS process_batch_key
FROM (

SELECT
  'CAP' as operating_group_type_uid
UNION ALL
SELECT
  'OPS' as operating_group_type_uid
UNION ALL
SELECT
  'BU' as operating_group_type_uid

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.operating_group_type t WHERE
	t.operating_group_type_uid = x.operating_group_type_uid
	AND t.source_key = @gov_source_key
);


/*
#######################################################################
Insert Content Records - Business Content
#######################################################################
*/

INSERT INTO dbo.operating_group_type (
  operating_group_type_key
, operating_group_type_desc
, operating_group_type_code
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT
  m.operating_group_type_key
, x.operating_group_type_desc
, x.operating_group_type_code
, @gov_source_key
, CURRENT_TIMESTAMP source_revision_dtm
, 'SYSTEM' source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key
FROM (

SELECT
  'CAP' as operating_group_type_uid
, 'Capability' AS operating_group_type_desc
, 'CAP' AS operating_group_type_code
UNION ALL
SELECT
  'OPS' as operating_group_type_uid
, 'Operations' AS operating_group_type_desc
, 'OPS' AS operating_group_type_code
UNION ALL
SELECT
  'BU' as operating_group_type_uid
, 'Business Unit' AS operating_group_type_desc
, 'BU' AS operating_group_type_code

) x

LEFT JOIN map.operating_group_type m ON
  m.source_key = @gov_source_key
  AND m.operating_group_type_uid = x.operating_group_type_uid

WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.operating_group_type t WHERE
    t.operating_group_type_key = m.operating_group_type_key
);
