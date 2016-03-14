CREATE TABLE [dbo].[project_type]
(
	project_type_key INT not null
,   project_type_desc VARCHAR(100) not null
,   project_type_code VARCHAR(20) not null
,	work_type VARCHAR(20) NOT NULL
,   internal_flag CHAR(1) null,
	[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT project_type_pk PRIMARY KEY CLUSTERED (project_type_key ASC)
);