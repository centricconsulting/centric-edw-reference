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

TRUNCATE TABLE dbo.Currency

INSERT INTO dbo.Currency (
  CurrencyCode
, CurrencyDesc
, CurrencySymbol
, process_batch_key
)
SELECT
  x.*
, @unknown_key AS process_batch_key
FROM
(

SELECT
  'ALL' AS CurrencyCode
, 'Albania Lek' AS CurrencyDesc
, N'Lek' AS CurrencySymbol
UNION ALL SELECT 'AFN','Afghanistan Afghani',N'؋'
UNION ALL SELECT 'ANG','Netherlands Antilles Guilder',N'ƒ'
UNION ALL SELECT 'ARS','Argentina Peso',N'$'
UNION ALL SELECT 'AUD','Australia Dollar',N'$'
UNION ALL SELECT 'AWG','Aruba Guilder',N'ƒ'
UNION ALL SELECT 'AZN','Azerbaijan New Manat',N'ман'
UNION ALL SELECT 'BAM','Bosnia and Herzegovina Convertible Marka',N'KM'
UNION ALL SELECT 'BBD','Barbados Dollar',N'$'
UNION ALL SELECT 'BGN','Bulgaria Lev',N'лв'
UNION ALL SELECT 'BMD','Bermuda Dollar',N'$'
UNION ALL SELECT 'BND','Brunei Darussalam Dollar',N'$'
UNION ALL SELECT 'BOB','Bolivia Bolíviano',N'$b'
UNION ALL SELECT 'BRL','Brazil Real',N'R$'
UNION ALL SELECT 'BSD','Bahamas Dollar',N'$'
UNION ALL SELECT 'BWP','Botswana Pula',N'P'
UNION ALL SELECT 'BYR','Belarus Ruble',N'p.'
UNION ALL SELECT 'BZD','Belize Dollar',N'BZ$'
UNION ALL SELECT 'CAD','Canada Dollar',N'$'
UNION ALL SELECT 'CHF','Switzerland Franc',N'CHF'
UNION ALL SELECT 'CLP','Chile Peso',N'$'
UNION ALL SELECT 'CNY','China Yuan Renminbi',N'¥'
UNION ALL SELECT 'COP','Colombia Peso',N'$'
UNION ALL SELECT 'CRC','Costa Rica Colon',N'₡'
UNION ALL SELECT 'CUP','Cuba Peso',N'₱'
UNION ALL SELECT 'CZK','Czech Republic Koruna',N'Kč'
UNION ALL SELECT 'DKK','Denmark Krone',N'kr'
UNION ALL SELECT 'DOP','Dominican Republic Peso',N'RD$'
UNION ALL SELECT 'EGP','Egypt Pound',N'£'
UNION ALL SELECT 'EUR','Euro Member Countries',N'€'
UNION ALL SELECT 'FJD','Fiji Dollar',N'$'
UNION ALL SELECT 'FKP','Falkland Islands (Malvinas) Pound',N'£'
UNION ALL SELECT 'GBP','United Kingdom Pound',N'£'
UNION ALL SELECT 'GGP','Guernsey Pound',N'£'
UNION ALL SELECT 'GHS','Ghana Cedi',N'¢'
UNION ALL SELECT 'GIP','Gibraltar Pound',N'£'
UNION ALL SELECT 'GTQ','Guatemala Quetzal',N'Q'
UNION ALL SELECT 'GYD','Guyana Dollar',N'$'
UNION ALL SELECT 'HKD','Hong Kong Dollar',N'$'
UNION ALL SELECT 'HNL','Honduras Lempira',N'L'
UNION ALL SELECT 'HRK','Croatia Kuna',N'kn'
UNION ALL SELECT 'HUF','Hungary Forint',N'Ft'
UNION ALL SELECT 'IDR','Indonesia Rupiah',N'Rp'
UNION ALL SELECT 'ILS','Israel Shekel',N'₪'
UNION ALL SELECT 'IMP','Isle of Man Pound',N'£'
UNION ALL SELECT 'INR','India Rupee',N'₹'
UNION ALL SELECT 'IRR','Iran Rial',N'﷼'
UNION ALL SELECT 'ISK','Iceland Krona',N'kr'
UNION ALL SELECT 'JEP','Jersey Pound',N'£'
UNION ALL SELECT 'JMD','Jamaica Dollar',N'J$'
UNION ALL SELECT 'JPY','Japan Yen',N'¥'
UNION ALL SELECT 'KGS','Kyrgyzstan Som',N'лв'
UNION ALL SELECT 'KHR','Cambodia Riel',N'៛'
UNION ALL SELECT 'KPW','Korea (North) Won',N'₩'
UNION ALL SELECT 'KRW','Korea (South) Won',N'₩'
UNION ALL SELECT 'KYD','Cayman Islands Dollar',N'$'
UNION ALL SELECT 'KZT','Kazakhstan Tenge',N'лв'
UNION ALL SELECT 'LAK','Laos Kip',N'₭'
UNION ALL SELECT 'LBP','Lebanon Pound',N'£'
UNION ALL SELECT 'LKR','Sri Lanka Rupee',N'₨'
UNION ALL SELECT 'LRD','Liberia Dollar',N'$'
UNION ALL SELECT 'MKD','Macedonia Denar',N'ден'
UNION ALL SELECT 'MNT','Mongolia Tughrik',N'₮'
UNION ALL SELECT 'MUR','Mauritius Rupee',N'₨'
UNION ALL SELECT 'MXN','Mexico Peso',N'$'
UNION ALL SELECT 'MYR','Malaysia Ringgit',N'RM'
UNION ALL SELECT 'MZN','Mozambique Metical',N'MT'
UNION ALL SELECT 'NAD','Namibia Dollar',N'$'
UNION ALL SELECT 'NGN','Nigeria Naira',N'₦'
UNION ALL SELECT 'NIO','Nicaragua Cordoba',N'C$'
UNION ALL SELECT 'NOK','Norway Krone',N'kr'
UNION ALL SELECT 'NPR','Nepal Rupee',N'₨'
UNION ALL SELECT 'NZD','New Zealand Dollar',N'$'
UNION ALL SELECT 'OMR','Oman Rial',N'﷼'
UNION ALL SELECT 'PAB','Panama Balboa',N'B/.'
UNION ALL SELECT 'PEN','Peru Sol',N'S/.'
UNION ALL SELECT 'PHP','Philippines Peso',N'₱'
UNION ALL SELECT 'PKR','Pakistan Rupee',N'₨'
UNION ALL SELECT 'PLN','Poland Zloty',N'zł'
UNION ALL SELECT 'PYG','Paraguay Guarani',N'Gs'
UNION ALL SELECT 'QAR','Qatar Riyal',N'﷼'
UNION ALL SELECT 'RON','Romania New Leu',N'lei'
UNION ALL SELECT 'RSD','Serbia Dinar',N'Дин.'
UNION ALL SELECT 'RUB','Russia Ruble',N'руб'
UNION ALL SELECT 'SAR','Saudi Arabia Riyal',N'﷼'
UNION ALL SELECT 'SBD','Solomon Islands Dollar',N'$'
UNION ALL SELECT 'SCR','Seychelles Rupee',N'₨'
UNION ALL SELECT 'SEK','Sweden Krona',N'kr'
UNION ALL SELECT 'SGD','Singapore Dollar',N'$'
UNION ALL SELECT 'SHP','Saint Helena Pound',N'£'
UNION ALL SELECT 'SOS','Somalia Shilling',N'S'
UNION ALL SELECT 'SRD','Suriname Dollar',N'$'
UNION ALL SELECT 'SVC','El Salvador Colon',N'$'
UNION ALL SELECT 'SYP','Syria Pound',N'£'
UNION ALL SELECT 'THB','Thailand Baht',N'฿'
UNION ALL SELECT 'TRY','Turkey Lira',N'0'
UNION ALL SELECT 'TTD','Trinidad and Tobago Dollar',N'TT$'
UNION ALL SELECT 'TVD','Tuvalu Dollar',N'$'
UNION ALL SELECT 'TWD','Taiwan New Dollar',N'NT$'
UNION ALL SELECT 'UAH','Ukraine Hryvnia',N'₴'
UNION ALL SELECT 'USD','United States Dollar',N'$'
UNION ALL SELECT 'UYU','Uruguay Peso',N'$U'
UNION ALL SELECT 'UZS','Uzbekistan Som',N'лв'
UNION ALL SELECT 'VEF','Venezuela Bolivar',N'Bs'
UNION ALL SELECT 'VND','Viet Nam Dong',N'₫'
UNION ALL SELECT 'XCD','East Caribbean Dollar',N'$'
UNION ALL SELECT 'YER','Yemen Rial',N'﷼'
UNION ALL SELECT 'ZAR','South Africa Rand',N'R'
UNION ALL SELECT 'ZWD','Zimbabwe Dollar',N'Z$'


) x
;