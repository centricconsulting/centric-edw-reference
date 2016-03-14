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
  @dw_source_key int
, @gov_source_key int
, @process_batch_key int = 0
, @environment varchar(20) = 'development'

, @unk_key int = 0
, @unk_uid varchar(20) = 'UNK'
, @unk_desc varchar(200) = 'Unknown'

, @na_key int = -1
, @na_uid varchar(20) = 'NA'
, @na_desc varchar(200) = 'Not Applicable';

/*
#######################################################################
IMPORTANT!!!
EXECUTE 1st: Seed the source table
EXECUTE 2nd: Lookup the @xxx_source_keys
#######################################################################
*/

:r .\seed_source.sql

SELECT @dw_source_key = source_key FROM map.source WHERE source_uid = 'DW';
SELECT @gov_source_key = source_key FROM map.source WHERE source_uid = 'GOV';

/*
#######################################################################
Seed remaining tables
#######################################################################
*/


:r .\drop_foreign_keys.sql

:r .\seed_calendar.sql

:r .\seed_operating_group_type.sql

:r .\seed_resource_type.sql

:r .\seed_gl_tran.sql

:r .\seed_operating_group.sql

:r .\seed_project_stage.sql

:r .\seed_project_type.sql

:r .\seed_project.sql

:r .\seed_client.sql

:r .\seed_resource.sql

:r .\seed_operating_group_projection.sql

:r .\seed_project_resource_plan.sql