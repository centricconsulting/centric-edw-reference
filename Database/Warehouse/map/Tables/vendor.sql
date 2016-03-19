CREATE TABLE [map].[vendor] (
    [vendor_key] INT           IDENTITY (100, 1) NOT NULL,
    [source_key] INT           NOT NULL,
    [vendor_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]  INT           NOT NULL,
    CONSTRAINT [dbo_vendor_pk] PRIMARY KEY CLUSTERED ([vendor_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dbo_vendor_gx]
    ON [map].[vendor]([vendor_uid] ASC, [source_key] ASC);

