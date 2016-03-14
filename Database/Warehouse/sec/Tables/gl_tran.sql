CREATE TABLE [sec].[gl_tran] (
    [gl_tran_key]             INT           NOT NULL,
    
	employee_key INT NOT NULL,
	employee_salary_amt money,
	employee_benefit_amt money,
	
	memo VARCHAR(1000),

	[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [gl_tran_pk] PRIMARY KEY CLUSTERED ([gl_tran_key] ASC)
);

