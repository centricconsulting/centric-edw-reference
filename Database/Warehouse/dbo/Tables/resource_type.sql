CREATE TABLE [dbo].[resource_type] (
    [resource_type_key]             INT           NOT NULL,
	resource_type_desc varchar(100) NOT NULL,
	resource_type_code varchar(20) NOT NULL,
	employee_flag char(1) NULL,
	[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [resource_type_pk] PRIMARY KEY CLUSTERED ([resource_type_key] ASC)
);

	