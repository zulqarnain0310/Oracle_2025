--------------------------------------------------------
--  DDL for Table STAGE_TERADATA_LOG
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_TERADATA_LOG" 
   (	"LINE" NUMBER, 
	"LOGSTRING" VARCHAR2(2000 CHAR)
   ) ON COMMIT PRESERVE ROWS ;
