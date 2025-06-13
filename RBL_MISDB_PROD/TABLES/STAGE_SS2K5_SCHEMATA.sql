--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_SCHEMATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_SS2K5_SCHEMATA" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"SUID_GEN" NUMBER(38,0), 
	"SCHEMA_OWNER" VARCHAR2(256 CHAR), 
	"SCHEMA_NAME" VARCHAR2(256 CHAR)
   ) ON COMMIT PRESERVE ROWS ;
