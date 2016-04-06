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

DECLARE
  @unknown_key int = 0
;

:r .\Seed.FiscalPeriod.sql

:r .\Seed.Holiday.sql

:r .\Seed.CurrencyExchangeRate.sql

:r .\Seed.CountryForecast.sql

:r .\Seed.StateProvince.sql

:r .\Seed.Currency.sql