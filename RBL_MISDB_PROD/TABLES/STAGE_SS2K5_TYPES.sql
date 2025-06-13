--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_TYPES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_SS2K5_TYPES" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"USER_TYPE_ID" NUMBER(38,0), 
	"SYSTEM_TYPE_ID" NUMBER(3,0), 
	"SCHEMA_ID" NUMBER(38,0), 
	"MAX_LENGTH" NUMBER(38,0), 
	"PRECISION" NUMBER(38,0), 
	"SCALE" NUMBER(38,0)
   ) ON COMMIT PRESERVE ROWS ;
