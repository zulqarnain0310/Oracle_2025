--------------------------------------------------------
--  DDL for Table TT_CUSTOMERENTITYID
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_CUSTOMERENTITYID" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"ID" NUMBER(3,0) DEFAULT 0
   ) ON COMMIT DELETE ROWS ;
