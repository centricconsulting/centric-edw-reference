CREATE TABLE [dbo].project_resource_book (
	[project_resource_book_key] INT NOT NULL,
    [project_key]               INT             NOT NULL,
    [resource_key]              INT             NOT NULL,
    [start_date_key]                 INT             NOT NULL,
    [end_date_key]                  INT             NOT NULL,
    [utilization_rate]  DECIMAL(20,12) NOT NULL,
	[bill_rate] money NOT NULL,
	[charge_flag] char(1) NOT NULL,
    [source_key]                INT             NOT NULL,
    [source_revision_dtm]       DATETIME        NOT NULL,
    [source_revision_actor]     VARCHAR (200)   NULL,
    [init_process_batch_key]    INT             NOT NULL,
    [process_batch_key]         INT             NOT NULL,
    CONSTRAINT [project_resource_book_pk] PRIMARY KEY CLUSTERED ([project_resource_book_key] ASC)
);



