CREATE TABLE [dbo].[QB_AR] (
    [process_batch_key]     INT             NOT NULL,
	FileName VARCHAR(200) NOT NULL,
	RecordNo INT NOT NULL,
	FileDatetime  DATETIME NOT NULL,
    [ClientName]            VARCHAR (100)   NOT NULL,
    [ProjectName]           VARCHAR (100)   NOT NULL,
    [BusinessUnit]          VARCHAR (50)    NULL,
    [TransactionType]       VARCHAR (50)    NULL,
    [TransactionDate]       DATETIME        NULL,
    [TransactionNumber]     VARCHAR (50)    NULL,
    [TransactionTerms]      VARCHAR (50)    NULL,
    [TransactionDueDate]    DATETIME        NULL,
    [TransactionAgingDays]  INT             NULL,
    [TransactionAgingGroup] VARCHAR (50)    NULL,
    [TransactionAmount]     DECIMAL (18, 2) NULL,
    [InsertDateTime]        DATETIME        NOT NULL,
	CONSTRAINT qb_ar_pk PRIMARY KEY CLUSTERED ([FileName] ASC, [RecordNo] ASC)
);

