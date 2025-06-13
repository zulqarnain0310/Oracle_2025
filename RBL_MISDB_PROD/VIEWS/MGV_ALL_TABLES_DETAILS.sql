--------------------------------------------------------
--  DDL for View MGV_ALL_TABLES_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "RBL_MISDB_PROD"."MGV_ALL_TABLES_DETAILS" ("OBJTYPE", "OBJNAME", "OBJID", "MAINOBJTYPE", "MAINOBJNAME", "MAINOBJID", "SCHEMANAME", "SCHEMAID", "CATALOGNAME", "CATALOGID", "CONNNAME", "CONNID", "PROJECTNAME", "PROJECTID", "CAPTUREDORCONVERTED", "QUALIFIEDNAME") AS 
  SELECT 'MD_TABLES' objtype, t.table_name objname, t.id objid,  'MD_TABLES' MainObjType,t.table_name MAINOBJNAME, t.id MAINOBJID, s.name SchemaName, s.id schemaid, cat.catalog_name catalogname,cat.id catalogid, conn.name connname,conn.id  connid,proj.project_name projectname,proj.id projectid,
NVL(conn.type,'CAPTURED') CapturedOrConverted, 
CASE WHEN conn.type IS NULL THEN   md_meta.quote(cat.catalog_name,s.name,t.table_name,conn.id)
                            ELSE   s.name || '.' || t.table_name END QualifiedName
FROM MD_TABLES t,MD_SCHEMAS s, MD_CATALOGS cat,MD_CONNECTIONS conn, MD_PROJECTS proj
WHERE t.schema_id_fk = s.id
AND s.catalog_id_fk = cat.id
AND cat.connection_id_fk = conn.id
AND conn.PROJECT_ID_FK = proj.id
;
