--------------------------------------------------------
--  DDL for Table GTT_BUSINESSRULESETUPDATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_BUSINESSRULESETUPDATA" 
   (	"UNIQUEID" VARCHAR2(20 BYTE), 
	"BUSINESSCOLALT_KEY" VARCHAR2(20 BYTE), 
	"SCOPE" VARCHAR2(20 BYTE), 
	"PARAMETERNAME" VARCHAR2(20 BYTE), 
	"BUSINESSCOLVALUES1" VARCHAR2(20 BYTE), 
	"BUSINESSCOLVALUES2" VARCHAR2(20 BYTE)
   ) ON COMMIT DELETE ROWS ;
