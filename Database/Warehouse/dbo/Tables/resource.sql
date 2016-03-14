CREATE TABLE [dbo].[resource] (
    [resource_key]           INT           NOT NULL,
    [first_name]             VARCHAR (50)  NULL,
    [last_name]              VARCHAR (50)  NULL,
    [full_name]              VARCHAR (200) NULL,
    [full_name_collated]     VARCHAR (200) NULL,
    [effective_begin_dt]     DATE          NULL,
    [effective_end_dt]       DATE          NULL,
    [resource_type_key]      INT           NOT NULL,
    [operating_group_key]    INT           NOT NULL,
    [job_title]              VARCHAR (50)  NULL,
    [bu_lead_flag]           CHAR (1)      NULL,
    [partner_flag]           CHAR (1)      NULL,
    [bench_flag]             CHAR (1)      NULL,
    [birth_dt]               DATE          NULL,
    [network_login]          VARCHAR (200) NULL,
    [email_address]          VARCHAR (200) NULL,
    [personal_email_address] VARCHAR (200) NULL,
    [company_name]           VARCHAR (100) NULL,
    [hire_dt]                DATE          NULL,
    [termination_dt]         DATE          NULL,
    [career_track]           VARCHAR (50)  NULL,
    [source_key]             INT           NOT NULL,
    [source_revision_dtm]    DATETIME      NOT NULL,
    [source_revision_actor]  VARCHAR (200) NULL,
    [init_process_batch_key] INT           NOT NULL,
    [process_batch_key]      INT           NOT NULL,
    CONSTRAINT [resource_pk] PRIMARY KEY CLUSTERED ([resource_key] ASC)
);







