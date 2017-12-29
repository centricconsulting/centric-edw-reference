CREATE TABLE [dbo].[StateProvince]
(
  CountryCode varchar(20) NOT NULL
, StateProvinceCode varchar(20) NOT NULL
, StateProvinceDesc varchar(200) NOT NULL
, StateProvinceType varchar(200) NOT NULL
, CountryDesc varchar(200) NOT NULL
, WorldSubregion varchar(200) NOT NULL
, WorldRegion varchar(200) NOT NULL
, process_batch_key INT NOT NULL
, CONSTRAINT dbo_StateProvince_PK PRIMARY KEY (StateProvinceCode, CountryCode)
)
