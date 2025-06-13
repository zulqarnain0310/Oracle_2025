--------------------------------------------------------
--  DDL for Table GTT_ACENT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ETL_TEMP_RBL_TEMPDB"."GTT_ACENT" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"ACCOUNTENTITYID" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
