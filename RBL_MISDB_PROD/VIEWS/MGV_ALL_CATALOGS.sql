--------------------------------------------------------
--  DDL for View MGV_ALL_CATALOGS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "RBL_MISDB_PROD"."MGV_ALL_CATALOGS" ("PROJECT_ID", "PROJECT_NAME", "CONNECTION_ID", "HOST", "PORT", "USERNAME", "DBURL", "CATALOG_ID", "CATALOG_NAME") AS 
  SELECT md_projects.id project_id ,
    md_projects.project_name project_name,
    md_connections.id connection_id ,
    md_connections.host host ,
    md_connections.port port ,
    md_connections.username username ,
    md_connections.dburl dburl ,
    md_catalogs.id catalog_id ,
    md_catalogs.catalog_name catalog_name
  FROM md_projects ,
    md_connections,
    md_catalogs
  WHERE md_catalogs.connection_id_fk = md_connections.id
  AND md_connections.project_id_fk   = md_projects.id
WITH READ ONLY
;
