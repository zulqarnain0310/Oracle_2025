--------------------------------------------------------
--  DDL for Table TT_UCIF
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_UCIF" 
   (	"UCIF_ID" VARCHAR2(50 CHAR), 
	"UCIFENTITYID" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
