CREATE TABLE [cdm].[batch_error] (
    [batch_key]     INT            NOT NULL,
    [error_type_cd] CHAR (1)       NULL,
    [error_scope]   VARCHAR (200)  NULL,
    [error_number]  INT            NULL,
    [error_message] VARCHAR (2000) NULL,
    [log_dtm]       DATETIME       DEFAULT (getdate()) NULL
);

