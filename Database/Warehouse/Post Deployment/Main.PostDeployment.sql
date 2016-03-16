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
Prepare Variables
#######################################################################
*/

DECLARE
  @unknown_key int = 0
, @unknown_uid varchar(20) = 'UNK'
, @unknown_desc varchar(200) = 'Unknown'

, @not_applicable_key int = -1
, @not_applicable_uid varchar(20) = 'NA'
, @not_applicable_desc varchar(200) = 'Not Applicable'

, @unresolved_key int = -2
, @unresolved_uid varchar(20) = 'UNR'
, @unresolved_desc varchar(200) = 'Unresolved'
;


/*
#######################################################################
IMPORTANT!!!
EXECUTE 1st: Seed the source table
EXECUTE 2nd: Lookup the @xxx_source_keys
#######################################################################
*/


DECLARE
  @dw_source_uid varchar(20) = 'DW'
, @gov_source_uid varchar(20) = 'GOV'
, @dw_source_key int
, @gov_source_key int
;

:r .\seed_source.sql

SELECT @dw_source_key = source_key FROM map.source WHERE source_uid = @dw_source_uid;
SELECT @gov_source_key = source_key FROM map.source WHERE source_uid = @gov_source_uid;

/*
#######################################################################
Seed remaining tables
#######################################################################
*/

:r .\seed_calendar.sql