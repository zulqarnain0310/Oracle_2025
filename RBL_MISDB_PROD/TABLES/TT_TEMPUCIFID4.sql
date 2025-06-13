--------------------------------------------------------
--  DDL for Table TT_TEMPUCIFID4
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMPUCIFID4" 
   (	"UCIF_ID" VARCHAR2(50 CHAR), 
	"DPD_MAX" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
