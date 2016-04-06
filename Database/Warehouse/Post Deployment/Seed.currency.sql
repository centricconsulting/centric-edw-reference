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


SET IDENTITY_INSERT map.currency ON;

INSERT INTO map.currency (
  currency_key
, source_key
, currency_uid
, process_batch_key
)
SELECT 
  x.currency_key
, x.source_key
, x.currency_uid
, @unknown_key AS process_batch_key
FROM (

SELECT 
  @unknown_key AS currency_key
, @unknown_uid AS currency_uid
, @warehouse_source_key AS source_key


UNION ALL
SELECT 
  @not_applicable_key AS currency_key
, @not_applicable_uid AS currency_uid
, @warehouse_source_key AS source_key

) x
WHERE
NOT EXISTS (
	SELECT 1 FROM map.currency m WHERE m.currency_key = x.currency_key
)
;

SET IDENTITY_INSERT map.currency OFF;


/*
############################################################
Populate the source table.
############################################################
*/

INSERT INTO dbo.currency (
  currency_key
, currency_desc
, currency_code
, source_key
, source_revision_actor
, source_revision_dtm
, init_process_batch_key
, process_batch_key
)
SELECT 
  m.currency_key
, x.currency_desc
, x.currency_code
, x.source_key
, NULL AS source_revision_actor
, CURRENT_TIMESTAMP AS source_revision_dtm
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key

FROM (

SELECT 
  @unknown_uid AS currency_uid
, @warehouse_source_key AS source_key
, @unknown_desc AS currency_desc
, @unknown_code AS currency_code

UNION ALL 
SELECT 
  @not_applicable_uid AS currency_uid
, @warehouse_source_key AS source_key
, @not_applicable_desc AS currency_desc
, @not_applicable_code AS currency_code

) x
INNER JOIN map.currency m ON
  m.source_key = x.source_key
  AND m.currency_uid = x.currency_uid

WHERE
NOT EXISTS (
	SELECT 1 FROM dbo.currency c WHERE c.currency_key = m.currency_key
)