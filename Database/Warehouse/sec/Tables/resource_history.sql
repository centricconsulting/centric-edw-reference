CREATE TABLE [sec].[resource_history] (

    [resource_key]           INT           NOT NULL,
	[status_date_key] INT NOT NULL,

	nominal_salary_amt money,

	[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [resource_history_pk] PRIMARY KEY CLUSTERED ([resource_key] ASC, [status_date_key] ASC)
);

