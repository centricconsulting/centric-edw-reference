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


SET IDENTITY_INSERT map.customer_type ON;

INSERT INTO map.customer_type (
  customer_type_key
, customer_type_uid
, process_batch_key
)
SELECT 
  x.customer_type_key
, x.customer_type_uid
, @unknown_key AS process_batch_key
FROM (

SELECT 
  @unknown_key AS customer_type_key
, @warehouse_source_uid AS customer_type_uid

UNION ALL
SELECT 
  @not_applicable_key AS customer_type_key
, @warehouse_source_uid AS customer_type_uid

UNION ALL
SELECT 100, 'BUSINESS'

UNION ALL
SELECT 101, 'CONSUMER'

) x
WHERE
NOT EXISTS (
	SELECT 1 FROM map.customer_type m WHERE m.customer_type_key = x.customer_type_key
)
;

SET IDENTITY_INSERT map.customer_type OFF;


/*
############################################################
Populate the source table.
############################################################
*/

INSERT INTO dbo.customer_type (
  customer_type_key
, customer_type_desc
, customer_type_code
, source_key
, source_revision_actor
, source_revision_dtm
, init_process_batch_key
, process_batch_key
)
SELECT 
  m.customer_type_key
, x.customer_type_desc
, x.customer_type_code
, x.source_key
, NULL AS source_revision_actor
, CURRENT_TIMESTAMP AS source_revision_dtm
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key

FROM (

SELECT 
  @unknown_uid AS customer_type_uid
, @warehouse_source_key AS source_key
, @unknown_desc AS customer_type_desc
, @unknown_code AS customer_type_code
, @warehouse_source_key AS source_key

UNION ALL 
SELECT 
  @not_applicable_uid AS customer_type_uid
, @warehouse_source_key AS source_key
, @not_applicable_desc AS customer_type_desc
, @not_applicable_code AS customer_type_code
, @warehouse_source_key AS source_key

UNION ALL 
SELECT 
  'BUSINESS' AS customer_type_uid
, @warehouse_source_key AS source_key
, 'Business' AS customer_type_desc
, 'B' AS customer_type_code
, @governance_source_key AS source_key

UNION ALL 
SELECT 
  'BUSINESS' AS customer_type_uid
, @warehouse_source_key AS source_key
, 'Business' AS customer_type_desc
, 'B' AS customer_type_code
, @governance_source_key AS source_key

) x
INNER JOIN map.customer m ON
  m.source_key = x.soure_key
  AND m.customer_type_uid = x.customer_type_uid

WHERE
NOT EXISTS (
	SELECT 1 FROM dbo.customer_type c WHERE c.customer_type_key = m.customer_type_key
)