--------------------------------------------------------
--  DDL for Table TT_MASTERTMP_2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_MASTERTMP_2" 
   (	"TABLENAME" CHAR(6 BYTE), 
	"CONTROLID" NUMBER(10,0), 
	"MASTERTABLE" VARCHAR2(50 CHAR)
   ) ON COMMIT DELETE ROWS ;
