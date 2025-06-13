--------------------------------------------------------
--  DDL for Table GTT_SPLITVALUE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_SPLITVALUE" 
   (	"UNIQUEID" VARCHAR2(20 BYTE), 
	"BUSINESSCOLVALUES1" "SYS"."ODCIVARCHAR2LIST" 
   ) ON COMMIT DELETE ROWS ;
