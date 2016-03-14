CREATE TABLE [dbo].[resource_history] (
    [resource_key]           INT           NOT NULL,
	[status_date_key] INT NOT NULL,

    [hire_date_key]          INT           NOT NULL,
    [terminate_date_key]   INT           NOT NULL,
    [resource_type_key]      INT           NOT NULL,

	[hire_flag] char(1),
	[terminate_flag] char(1),
    local_partner_flag char(1),
	national_partner_flag char(1),

	hire_dt date,
	termination_dt date,
	nominal_salary_amt money,

	[job_title]              VARCHAR (50)  NULL,
    [company_name]           VARCHAR (200) NULL,	

	[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [resource_history_pk] PRIMARY KEY CLUSTERED ([resource_key] ASC, [status_date_key] ASC)
);

