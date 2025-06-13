--------------------------------------------------------
--  DDL for Table STAGE_TERADATA_DATABASES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_TERADATA_DATABASES" 
   (	"SVRID" NUMBER, 
	"MDID" NUMBER, 
	"DATABASENAME" VARCHAR2(128 CHAR), 
	"COMMENTSTRING" VARCHAR2(255 CHAR), 
	"OWNERNAME" VARCHAR2(128 CHAR)
   ) ON COMMIT PRESERVE ROWS ;
