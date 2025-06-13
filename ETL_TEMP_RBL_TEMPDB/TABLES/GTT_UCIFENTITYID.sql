--------------------------------------------------------
--  DDL for Table GTT_UCIFENTITYID
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ETL_TEMP_RBL_TEMPDB"."GTT_UCIFENTITYID" 
   (	"UCIF_ID" VARCHAR2(30 CHAR), 
	"UCIFENTITYID" NUMBER
   ) ON COMMIT DELETE ROWS ;
