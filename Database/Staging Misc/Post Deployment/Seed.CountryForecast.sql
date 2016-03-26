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

TRUNCATE TABLE dbo.CountryForecast;

INSERT INTO dbo.CountryForecast (
  FiscalYear
, FiscalPeriodOfYear
, CountryCode
, ForecastCurrencyCode
, ForecastSales
, ForecastGrossMargin
, process_batch_key
)
SELECT
  YEAR(h.OrderDate) + YEAR(CURRENT_TIMESTAMP) - 2007 AS FiscalYear
, MONTH(h.OrderDate) AS FiscalPeriodOfYear
, sp.CountryRegionCode AS CountryCode
, 'USD' AS ForecastCurrencyCode
, ROUND(
    SUM(UnitPrice * OrderQty) 
    + ((CAST(SUM(UnitPrice * OrderQty) AS INT) % 30) - 16) / 100.0 * SUM(UnitPrice * OrderQty)
  , -3) AS ForecastSales

, .25 AS ForecastGrossMargin
, @unknown_key AS process_batch_key

FROM
AdventureWorks.Sales.SalesOrderDetail d
INNER JOIN AdventureWorks.Sales.SalesOrderHeader h ON h.SalesOrderID = d.SalesOrderID
INNER JOIN AdventureWorks.Person.Address a ON a.AddressID = h.ShipToAddressID
INNER JOIN AdventureWorks.Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID

WHERE
-- original years
YEAR(h.OrderDate) BETWEEN 2006 AND 2007

GROUP BY
  YEAR(h.OrderDate)
, MONTH(h.OrderDate)
, sp.CountryRegionCode

ORDER BY
  sp.CountryRegionCode
, YEAR(h.OrderDate)
, MONTH(h.OrderDate)
;

