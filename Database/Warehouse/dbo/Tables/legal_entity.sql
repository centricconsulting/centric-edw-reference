CREATE TABLE [dbo].[legal_entity]
(
    legal_entity_key INT IDENTITY(1000,1),

  -- GRAIN COLUMN(S)
    legal_entity_uid VARCHAR(200) NOT NULL,

    parent_legal_entity_uid VARCHAR(200) NULL,
    legal_entity_desc VARCHAR(200) NOT NULL,
    legal_entity_country_uid VARCHAR(200) NULL,
    gl_currency_uid VARCHAR(200) NULL,

    source_uid VARCHAR(200) NOT NULL,
    source_revision_dtm DATETIME NOT NULL,
    source_revision_actor VARCHAR(200) NULL,

    provision_batch_key int NOT NULL,
    revision_batch_key int NOT NULL,

    CONSTRAINT dbo_legal_entity_pk PRIMARY KEY CLUSTERED (legal_entity_uid)

)
