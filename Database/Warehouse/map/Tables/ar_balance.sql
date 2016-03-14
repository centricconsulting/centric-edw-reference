CREATE TABLE [map].[ar_balance] (
    [ar_balance_key]            INT           IDENTITY (100, 1) NOT NULL,
    [source_key]        INT           NOT NULL,
    [ar_balance_uid]            VARCHAR (200) NOT NULL,
    [process_batch_key] INT           NOT NULL,
    CONSTRAINT [ar_pk] PRIMARY KEY CLUSTERED ([ar_balance_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ar_balance_gx]
    ON [map].[ar_balance]([source_key] ASC, [ar_balance_uid] ASC);


