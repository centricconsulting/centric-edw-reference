CREATE TABLE dbo.geography (
  geography_key int NOT NULL

, country_code varchar(20) NOT NULL
, country_desc varchar(200) NOT NULL
, state_province_desc varchar(200) NOT NULL
, state_province_code varchar(100) NOT NULL
, unknown_state_province_ind bit NOT NULL

, world_subregion_desc varchar(200) NOT NULL
, world_region_desc varchar(200) NOT NULL

  -- BOILERPLATE: source columns
, source_key int NOT NULL
, source_revision_actor varchar(50) NULL
, source_revision_dtm datetime NOT NULL

  -- BOILERPLATE: audit columns
, init_process_batch_key int NOT NULL
, process_batch_key int NOT NULL

, CONSTRAINT geography_pk PRIMARY KEY (geography_key)
);