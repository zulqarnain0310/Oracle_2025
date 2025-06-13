--------------------------------------------------------
--  DDL for Type MIGR_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "ACL_RBL_MISDB_PROD"."MIGR_FILTER" IS OBJECT (
  FILTER_TYPE INTEGER, -- Filter Types are 0-> ALL, 1->NAMELIST, 2->WHERE CLAUSE, 3->OBJECTID LIST
  OBJTYPE VARCHAR2(40),
  OBJECTIDS OBJECTIDLIST,
  NAMES NAMELIST,
  WHERECLAUSE VARCHAR2(1000));

/
