--------------------------------------------------------
--  DDL for View MGV_ALL_CATALOG_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ACL_RBL_MISDB_PROD"."MGV_ALL_CATALOG_DETAILS" ("OBJTYPE", "OBJNAME", "OBJID", "MAINOBJTYPE", "MAINOBJNAME", "MAINOBJID", "SCHEMANAME", "SCHEMAID", "CATALOGNAME", "CATALOGID", "CONNNAME", "CONNID", "PROJECTNAME", "PROJECTID", "CAPTUREDORCONVERTED", "QUALIFIEDNAME") AS 
  SELECT 'MD_CATALOGS' objtype, cat.catalog_name objname, cat.id objid,  'MD_CATALOGS' MainObjType,cat.catalog_name MAINOBJNAME, cat.id MAINOBJID,null SchemaName,null schemaid, cat.catalog_name catalogname,cat.id catalogid, conn.name connname,conn.id  connid,proj.project_name projectname,proj.id projectid,
NVL(conn.type,'CAPTURED') CapturedOrConverted, 
CASE WHEN conn.type IS NULL THEN cat.catalog_name ELSE NULL END QualifiedName
FROM  MD_CATALOGS cat,MD_CONNECTIONS conn, MD_PROJECTS proj
WHERE  cat.connection_id_fk = conn.id
AND conn.PROJECT_ID_FK = proj.id
;
