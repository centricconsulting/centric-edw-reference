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

SET IDENTITY_INSERT map.customer ON;

INSERT INTO map.customer (
  customer_key
, source_key
, customer_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unknown_key as customer_key
, @warehouse_source_key AS source_key
, @unknown_uid as customer_uid
, @unknown_key as process_batch_key
UNION ALL
SELECT
  @not_applicable_key as customer_key
, @warehouse_source_key AS source_key
, @not_applicable_uid as customer_uid
, @unknown_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.customer t WHERE t.customer_key = x.customer_key
);

SET IDENTITY_INSERT map.customer OFF;


/*
#######################################################################
Insert Content Records
#######################################################################
*/


SET IDENTITY_INSERT ver.customer ON;


INSERT INTO ver.customer (
  customer_version_key
, customer_key
, customer_type_key
, geography_key
, customer_name
, primary_contact_name
, primary_contact_phone_nbr
, address_line1
, address_line2
, city
, state_desc
, country_desc
, postal_code
, address_lattitude
, address_longitude
, source_key
, source_revision_actor
, source_revision_begin_dtm
, source_revision_end_dtmx
, source_revision_action
, version_begin_dtm
, version_end_dtmx
, version_current_ind
, version_latest_ind
, version_pin_ind
, version_idx
, init_process_batch_key
, process_batch_key
)
SELECT 
  x.record_key AS customer_version_key
, x.record_key AS customer_key
, x.record_key AS customer_type_key
, x.record_key AS geography_key
, x.record_desc AS customer_name
, x.record_desc AS primary_contact_name
, NULL AS primary_contact_phone_nbr
, NULL AS address_line1
, NULL AS address_line2
, x.record_desc AS city
, x.record_desc AS state_desc
, x.record_desc AS country_desc
, x.record_desc AS postal_code
, NULL AS address_lattitude
, NULL AS address_longitude
, x.source_key
, NULL AS source_revision_actor
, x.source_revision_dtm AS source_revision_begin_dtm
, NULL source_revision_end_dtmx
, 'I' AS source_revision_action
, x.source_revision_dtm AS version_begin_dtm
, NULL AS version_end_dtmx
, 1 AS version_current_ind
, 1 AS version_latest_ind
, 0 AS version_pin_ind
, 0 AS version_idx
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key
FROM (

SELECT
  @unknown_key AS record_key
, @unknown_desc AS record_desc
, @warehouse_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key

UNION ALL

SELECT
  @not_applicable_key AS record_key
, @not_applicable_desc AS record_desc
, @warehouse_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM ver.customer v WHERE v.customer_version_key = x.record_key
);


SET IDENTITY_INSERT ver.customer OFF;
