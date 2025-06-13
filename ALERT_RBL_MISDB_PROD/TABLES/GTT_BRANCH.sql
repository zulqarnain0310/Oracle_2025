--------------------------------------------------------
--  DDL for Table GTT_BRANCH
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ALERT_RBL_MISDB_PROD"."GTT_BRANCH" 
   (	"BRANCHZONE" VARCHAR2(50 CHAR), 
	"BRANCHZONEALT_KEY" NUMBER(5,0), 
	"BRANCHREGION" VARCHAR2(50 CHAR), 
	"BRANCHREGIONALT_KEY" NUMBER(5,0)
   ) ON COMMIT DELETE ROWS ;
