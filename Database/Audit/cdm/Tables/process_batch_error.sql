CREATE TABLE [cdm].[process_batch_error] (
    [process_batch_key]     INT            NOT NULL,
    -- Error Type Code indicates whether the error is a warning or critical error
	[error_type_cd] VARCHAR(20)       NULL,
	-- Error Scope provides additional detail around the error and is application specific
    [error_scope]   VARCHAR (200)  NULL,
    [error_number]  INT            NULL,
    [error_message] VARCHAR (2000) NULL,
    [error_dtm]       DATETIME       DEFAULT (getdate()) NULL,
	[comments] VARCHAR(2000)
);

