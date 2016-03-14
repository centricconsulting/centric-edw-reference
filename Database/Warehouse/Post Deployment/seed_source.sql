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
Populate the source map table.
############################################################
*/

INSERT INTO map.source (
  source_key
, source_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT 
  @unk_key AS source_key
, 'DW' as source_uid
, @process_batch_key as process_batch_key
UNION ALL SELECT 100, 'DOV', 0
UNION ALL SELECT 101, 'APPS', 0
UNION ALL SELECT 102, 'ADP', 0
UNION ALL SELECT 103, 'GOV', 0
UNION ALL SELECT 104, 'CEDW', 0
UNION ALL SELECT 105, 'QB', 0

) x
WHERE
NOT EXISTS (
	SELECT 1 FROM map.source m WHERE m.source_key = x.source_key
)

/*
############################################################
Populate the source table.
############################################################
*/


INSERT INTO dbo.source (
  source_key
, source_name
, source_desc
, process_batch_key
)
SELECT x.* FROM (

SELECT 
  @unk_key AS source_key
, 'Data Warehouse' as source_name
, 'Centric Data Warehouse' AS source_desc
, @process_batch_key as process_batch_key
UNION ALL SELECT 100, 'Dovico','Centric time tracking applicition', 0
UNION ALL SELECT 101, 'Centric Apps','Centric internal operations applications', 0
UNION ALL SELECT 102, 'ADP', 'Centric payroll feeds',0
UNION ALL SELECT 103, 'Governance', 'Centric governance (master and mapping) data', 0
UNION ALL SELECT 104, 'Centric EDW', 'Prior Centric data warehouse; contains master data', 0
UNION ALL SELECT 105, 'QB', 'General Ledger data from QuickBooks', 0
) x
WHERE
NOT EXISTS (
	SELECT 1 FROM dbo.source m WHERE m.source_key = x.source_key
)