--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_SCHEMAS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_SS2K5_SCHEMAS" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"SUID_GEN" NUMBER(38,0), 
	"SCHEMA_ID" NUMBER(38,0), 
	"NAME" VARCHAR2(256 CHAR)
   ) ON COMMIT PRESERVE ROWS ;
