CREATE TABLE [dbo].[project_stage_history] (
    project_key             INT           NOT NULL,

	stage_begin_date_key INT NOT NULL,

	-- COMPUTED COLUMN: pulls the day prior to the next begin date, defaults to the extreme date
	/*
	stage_end_date_key AS COALESCE(
		LEAD(CAST(CONVERT(char(8),stage_begin_dt - 1, 112) AS INT)) OVER (
			PARTITION BY project_key ORDER BY stage_begin_date_key, [source_revision_dtm]
		), 29991231),
	*/

	stage_begin_dt DATE NOT NULL,
	stage_end_dt DATE,

	project_stage_key INT NOT NULL,
	budget_revenue_amt money NULL,
	prospect_revenue_amt money NULL,
	
	[source_key] INT NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [project_stage_history_pk] PRIMARY KEY CLUSTERED (project_key ASC, stage_begin_date_key ASC)
);

