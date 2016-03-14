

CREATE VIEW [cube].ops_client AS
SELECT client_key
, client_desc AS Client
FROM
dbo.client
;