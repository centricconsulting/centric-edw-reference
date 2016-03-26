CREATE TABLE ver.customer (
  -- version key
	customer_version_key int IDENTITY(100,1) NOT NULL,
	
  -- grain
	customer_key int NOT NULL, -- generated in the entity

  -- attributes
  -- NOTE: related attribute keys
  customer_type_key int NOT NULL,
  geography_key int,

  -- NOTE: other attributes besides keys
	customer_name varchar(200) NOT NULL,
	primary_contact_name varchar(200) NULL,
	primary_contact_phone_nbr varchar(50) NULL,
  
  address_line1 varchar(200) NULL,
  address_line2 varchar(200) NULL,
  city varchar(200) NULL,
  state_desc varchar(200),
  country_desc varchar(200),
  postal_code varchar(200),
  address_lattitude decimal(20,12),
  address_longitude decimal(20,12),
  
  -- BOILERPLATE: source columns
	source_key int NOT NULL,
	source_revision_actor varchar(50) NULL,
	source_revision_begin_dtm datetime NOT NULL,
	source_revision_end_dtmx datetime NULL,
	source_revision_action char(1) NOT NULL,

  -- BOILERPLATE: version columns
	version_begin_dtm datetime NOT NULL,
	version_end_dtmx datetime NULL,
	version_current_ind bit NULL,
	version_latest_ind bit NOT NULL,
	version_pin_ind bit NOT NULL,
	version_idx int NOT NULL,

  -- BOILERPLATE: audit columns
  init_process_batch_key int NOT NULL,
	process_batch_key int NOT NULL,

 CONSTRAINT ver_customer_pk PRIMARY KEY CLUSTERED  (customer_version_key)
) ON [PRIMARY]

GO

-- create the grain index
CREATE UNIQUE INDEX ver_customer_gx ON ver.customer (customer_key, version_idx)
GO

-- create the current index, used by view
CREATE UNIQUE INDEX ver_customer_cx ON ver.customer (customer_key) WHERE version_latest_ind = 1
GO