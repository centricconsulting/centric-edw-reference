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
############################################################
Populate the map table.

The primary method for seeding the map table is to turn all
inserting of IDENTITY column values and then insert seeded 
map records.

The Unknown and Not Applicable records are tagged with a
Data Warehouse source key.  Other manually maintained 
records are inserted with the Governance source key below
the original IDENTITY seed value (usually 1000) 


############################################################
*/


SET IDENTITY_INSERT map.geography ON;

INSERT INTO map.geography (
  geography_key
, source_key
, geography_uid
, process_batch_key
)
SELECT 
  x.geography_key
, x.source_key
, x.geography_uid
, @unknown_key AS process_batch_key
FROM (

  SELECT 
    @unknown_key AS geography_key
  , @unknown_uid AS geography_uid
  , @warehouse_source_key AS source_key


  UNION ALL
  SELECT 
    @not_applicable_key AS geography_key
  , @not_applicable_uid AS geography_uid
  , @warehouse_source_key AS source_key

) x
WHERE
NOT EXISTS (
	SELECT 1 FROM map.geography m WHERE m.geography_key = x.geography_key
)
;

SET IDENTITY_INSERT map.geography OFF;


/*
############################################################
Populate the source table.
############################################################
*/

INSERT INTO dbo.geography (
  geography_key
, country_code
, country_desc
, state_province_code
, state_province_desc
, unknown_state_province_ind
, world_subregion_desc
, world_region_desc
, source_key
, source_revision_actor
, source_revision_dtm
, init_process_batch_key
, process_batch_key
)
SELECT 
  m.geography_key
, x.country_code
, x.country_desc
, x.state_province_code
, x.state_province_desc
, x.unknown_state_province_ind
, x.world_subregion_desc
, x.world_region_desc
, x.source_key
, NULL AS source_revision_actor
, CURRENT_TIMESTAMP AS source_revision_dtm
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key

FROM (

  SELECT 
    @unknown_uid AS geography_uid
  , @warehouse_source_key AS source_key
  , @unknown_code AS country_code
  , @unknown_desc AS country_desc
  , @unknown_code AS state_province_code
  , @unknown_desc AS state_province_desc
  , 0 AS unknown_state_province_ind
  , @unknown_desc AS world_subregion_desc
  , @unknown_desc AS world_region_desc

  UNION ALL 
  SELECT 
    @not_applicable_uid AS geography_uid
  , @warehouse_source_key AS source_key
  , @not_applicable_code AS country_code
  , @not_applicable_desc AS country_desc
  , @not_applicable_code AS state_province_code
  , @not_applicable_desc AS state_province_desc
  , 0 AS unknown_state_province_ind
  , @not_applicable_desc AS world_subregion_desc
  , @not_applicable_desc AS world_region_desc

) x
INNER JOIN map.geography m ON
  m.source_key = x.source_key
  AND m.geography_uid = x.geography_uid

WHERE
NOT EXISTS (
	SELECT 1 FROM dbo.geography c WHERE c.geography_key = m.geography_key
)