CREATE TABLE [cdm].[process] (
    [process_uid]            VARCHAR (100) NOT NULL,
    [completed_batch_key]    INT           NULL,
    [completed_sequence_key] BIGINT        NULL,
    [completed_sequence_dtm] DATETIME      NULL,
    [initiate_dtm]           DATETIME      NULL,
    [conclude_dtm]           DATETIME      NULL,
    [duration_sec]           AS            (CONVERT([decimal](20,3),datediff(millisecond,[initiate_dtm],[conclude_dtm])/(1000.0))),
    CONSTRAINT [process_pk] PRIMARY KEY CLUSTERED ([process_uid] ASC)
);



