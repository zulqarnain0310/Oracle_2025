--------------------------------------------------------
--  DDL for Table GTT_CUSTENTITYID
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ETL_TEMP_RBL_TEMPDB"."GTT_CUSTENTITYID" 
   (	"CUSTOMERID" VARCHAR2(20 CHAR), 
	"CUSTOMERENTITYID" NUMBER
   ) ON COMMIT DELETE ROWS ;
