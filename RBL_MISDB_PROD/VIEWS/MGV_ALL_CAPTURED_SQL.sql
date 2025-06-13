--------------------------------------------------------
--  DDL for View MGV_ALL_CAPTURED_SQL
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "RBL_MISDB_PROD"."MGV_ALL_CAPTURED_SQL" ("OBJTYPE", "OBJNAME", "OBJID", "MAINOBJTYPE", "MAINOBJNAME", "MAINOBJID", "SCHEMANAME", "SCHEMAID", "CATALOGNAME", "CATALOGID", "CONNNAME", "CONNID", "PROJECTNAME", "PROJECTID", "CAPTUREDORCONVERTED", "QUALIFIEDNAME", "NATIVE_SQL", "LINECOUNT") AS 
  SELECT d."OBJTYPE",d."OBJNAME",d."OBJID",d."MAINOBJTYPE",d."MAINOBJNAME",d."MAINOBJID",d."SCHEMANAME",d."SCHEMAID",d."CATALOGNAME",d."CATALOGID",d."CONNNAME",d."CONNID",d."PROJECTNAME",d."PROJECTID",d."CAPTUREDORCONVERTED",d."QUALIFIEDNAME", p.native_sql,p.linecount 
FROM md_stored_programs p , mgv_all_programs_details d
WHERE p.id = d.objid
AND d.capturedorconverted = 'CAPTURED'
UNION ALL
SELECT d."OBJTYPE",d."OBJNAME",d."OBJID",d."MAINOBJTYPE",d."MAINOBJNAME",d."MAINOBJID",d."SCHEMANAME",d."SCHEMAID",d."CATALOGNAME",d."CATALOGID",d."CONNNAME",d."CONNID",d."PROJECTNAME",d."PROJECTID",d."CAPTUREDORCONVERTED",d."QUALIFIEDNAME",v.native_sql,v.linecount
FROM md_views v , mgv_all_view_details d
WHERE v.id = d.objid
AND d.capturedorconverted = 'CAPTURED'
UNION ALL
SELECT d."OBJTYPE",d."OBJNAME",d."OBJID",d."MAINOBJTYPE",d."MAINOBJNAME",d."MAINOBJID",d."SCHEMANAME",d."SCHEMAID",d."CATALOGNAME",d."CATALOGID",d."CONNNAME",d."CONNID",d."PROJECTNAME",d."PROJECTID",d."CAPTUREDORCONVERTED",d."QUALIFIEDNAME" ,t.native_sql,t.linecount
FROM md_triggers t , mgv_all_trigger_details d
WHERE t.id = d.objid
AND d.capturedorconverted = 'CAPTURED'
;
