--------------------------------------------------------
--  DDL for Table TT_TEMPRETURNDETAILS_2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMPRETURNDETAILS_2" 
   (	"RETURNID" NUMBER(10,0), 
	"REPORTID" VARCHAR2(4000 BYTE), 
	"PARENTRETURNID" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
