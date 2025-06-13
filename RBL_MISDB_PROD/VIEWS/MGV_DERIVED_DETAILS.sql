--------------------------------------------------------
--  DDL for View MGV_DERIVED_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "RBL_MISDB_PROD"."MGV_DERIVED_DETAILS" ("CAPCATALOGID", "CAPCATALOGNAME", "CAPCONNID", "CAPCONNNAME", "CAPMAINOBJID", "CAPMAINOBJNAME", "CAPMAINOBJTYPE", "CAPOBJID", "CAPOBJNAME", "CAPOBJTYPE", "CAPPROJECTID", "CAPPROJECTNAME", "CAPQUALIFIEDNAME", "CAPSCHEMAID", "CAPSCHEMANAME", "CONCATALOGID", "CONCATALOGNAME", "CONCONNID", "CONCONNNAME", "CONMAINOBJID", "CONMAINOBJNAME", "CONMAINOBJTYPE", "CONOBJID", "CONOBJNAME", "CONOBJTYPE", "CONPROJECTID", "CONPROJECTNAME", "CONQUALIFIEDNAME", "CONSCHEMAID", "CONSCHEMANAME", "DERIVATIVE_REASON", "TRANSFORMED") AS 
  select d1.catalogid capcatalogid,
   d1.catalogname capcatalogname,
   d1.connid capconnid,
   d1.connname capconnname,
   d1.mainobjid capmainobjid,
   d1.mainobjname capmainobjname,
   d1.mainobjtype capmainobjtype ,
   d1.objid capobjid,
   d1.objname capobjname,
   d1.objtype capobjtype,
   d1.projectid capprojectid,
   d1.projectname capprojectname,
   d1.qualifiedname capqualifiedname,
   d1.schemaid capschemaid,
   d1.schemaname capschemaname,
   d2.catalogid concatalogid,
   d2.catalogname concatalogname,
   d2.connid conconnid,
   d2.connname conconnname,
   d2.mainobjid conmainobjid,
   d2.mainobjname conmainobjname,
   d2.mainobjtype conmainobjtype ,
   d2.objid conobjid,
   d2.objname conobjname,
   d2.objtype conobjtype,
   d2.projectid conprojectid,
   d2.projectname conprojectname,
   d2.qualifiedname conqualifiedname,
   d2.schemaid conschemaid,
   d2.schemaname conschemaname,
    der.derivative_reason,
    der.transformed
  FROM mgv_all_details d1
  LEFT OUTER JOIN md_derivatives der
  ON der.src_id              = d1.objid
  AND der.derivative_reason IS NULL
  LEFT OUTER JOIN mgv_all_details d2
  ON der.derived_id            = d2.objid
  WHERE d1.capturedorconverted = 'CAPTURED'
  AND der.derivative_reason   IS NULL
;
