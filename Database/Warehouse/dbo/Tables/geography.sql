CREATE TABLE dbo.geography (

  geography_key int IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMN(S)
, geography_uid VARCHAR(200) NOT NULL

, country_code varchar(20) NOT NULL
, country_desc varchar(200) NOT NULL
, state_province_desc varchar(200) NOT NULL
, state_province_code varchar(100) NOT NULL

, world_subregion_desc varchar(200) NOT NULL
, world_region_desc varchar(200) NOT NULL

  -- BOILERPLATE: source columns
, source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT dbo_geography_pk PRIMARY KEY (geography_uid)
);