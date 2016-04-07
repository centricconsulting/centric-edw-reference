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
, @unknown_code varchar(20) = 'Unknown'
, @unknown_desc varchar(200) = 'Unknown'

, @not_applicable_key int = -1
, @not_applicable_uid varchar(20) = 'NA'
, @not_applicable_code varchar(200) = 'Not Applicable'
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
  @warehouse_source_uid varchar(20) = 'EDW'
, @governance_source_uid varchar(20) = 'GOV'
, @warehouse_source_key int
, @governance_source_key int
;

:r .\Seed.source.sql

-- lookup special source keys
SELECT @warehouse_source_key = source_key FROM map.source WHERE source_uid = @warehouse_source_uid;
SELECT @governance_source_key = source_key FROM map.source WHERE source_uid = @governance_source_uid;

/*
#######################################################################
Rebuild the calendars
#######################################################################
*/

DECLARE @current_dt date
SET @current_dt = GETDATE();

:r .\Seed.calendar.sql
:r .\Seed.fiscal_calendar.sql

/*
#######################################################################
Seed additional tables
#######################################################################
*/

:r .\Seed.currency.sql

:r .\Seed.customer.sql

:r .\Seed.geography.sql

:r .\Seed.customer_type.sql







