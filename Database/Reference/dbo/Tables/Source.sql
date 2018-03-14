CREATE TABLE [dbo].Source
(
  SourceCode VARCHAR(20) NOT NULL
, SourceName VARCHAR(200) NOT NULL
, CONSTRAINT dbo_Source_PK  PRIMARY KEY (SourceCode)
);
GO

CREATE UNIQUE INDEX dbo_Source_U1 ON dbo.Source (SourceName);
