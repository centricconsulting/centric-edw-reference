CREATE TABLE [cdm].[process_batch] (
    [process_batch_key]           INT         NOT NULL,
    [process_uid]                 VARCHAR (200)  NOT NULL,
	[channel_uid]                 VARCHAR (200)  NOT NULL,
    [status]                      VARCHAR (100)  NULL,
    [completed_ind]               SMALLINT DEFAULT 0 NULL,
    [initiate_dtm]                DATETIME      NULL,
    [conclude_dtm]                DATETIME      NULL,

	[duration_sec] AS

		CASE
		-- only report duration when 5 days or less
		WHEN conclude_dtm - initiate_dtm <= 5 THEN
		CONVERT([decimal](20,3),datediff(millisecond,[initiate_dtm],[conclude_dtm])/1000.0)
		END,

    [source_record_ct]            INT           NULL,
    [inserted_record_ct]          INT           NULL,
    [updated_record_ct]           INT           NULL,
    [deleted_record_ct]           INT           NULL,
    [advanced_version_record_ct]  INT           NULL,
    [collapsed_version_record_ct] INT           NULL,
    [revised_record_ct]           INT           NULL,
    [unprocessed_record_ct]       INT           NULL,
    [exception_record_ct]         INT           NULL,
    [current_sequence_val]        BIGINT        NULL,
    [current_sequence_dtm]        DATETIME      NULL,
    [prior_process_batch_key]     BIGINT        NULL,
    [begin_sequence_val]          BIGINT        NULL,
    [begin_sequence_dtm]          DATETIME      NULL,
    [limit_process_uid]           VARCHAR (200)  NULL,
    [limit_channel_uid]           VARCHAR (200)  NULL,
    [limit_process_batch_key]     INT         NULL,
    [end_sequence_val]            BIGINT        NULL,
    [end_sequence_dtm]            DATETIME      NULL,
	-- scope describes the data addressed by the batch, where applicable
	[scope]                       VARCHAR (200) NULL,
    [workflow_name]               VARCHAR (200) NULL,
    [workflow_guid]               VARCHAR (100) NULL,
    [workflow_version]            VARCHAR (20) NULL,
    [comments]                    VARCHAR (2000) NULL,
    CONSTRAINT [process_batch_pk] PRIMARY KEY CLUSTERED ([process_batch_key] ASC)
);

