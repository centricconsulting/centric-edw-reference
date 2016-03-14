use warehouse
go

drop table map.source_map
GO

create table map.source_map (
  source_key bigint NOT NULL
, source_uid varchar(200) NOT NULL
, dmproc_batch_key bigint 
, CONSTRAINT source_map_pk PRIMARY KEY (source_key)
);

create unique index source_map_gx ON map.source_map (source_uid)
GO

drop table [source]
go

CREATE TABLE [dbo].[source](
	[source_key] [bigint] NOT NULL,
	[source_name] [varchar](50) NOT NULL,
	[source_desc] [varchar](100) NULL,
	[dmproc_batch_key] [bigint] NOT NULL,
 CONSTRAINT [source_pk] PRIMARY KEY CLUSTERED 
(
	[source_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


INSERT INTO map.source_map VALUES
  (100, 'DW',0)
, (200, 'GOV',0)
, (201, 'QB',0)
, (202, 'CENAPPS',0)
, (203, 'DOVICO',0)
, (204, 'ADP',0);

GO


INSERT INTO dbo.source VALUES
  (100, 'Data Warehouse','Data Warehouse', 0)
, (200, 'Governance Repository', 'Repository for data enrichmemnt, condolidation and cross-reference', 0)
, (201, 'Quickbooks','Financial system of record', 0)
, (202, 'CENAPPS', 'Centric internal applications',0)
, (203, 'DOVICO', 'Centric time tracking', 0)
, (204, 'ADP','Payroll',0);


select * from map.source_map
select * from source