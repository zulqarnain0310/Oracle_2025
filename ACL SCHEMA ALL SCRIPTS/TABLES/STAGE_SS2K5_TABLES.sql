--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_TABLES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."STAGE_SS2K5_TABLES" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"OBJID_GEN" NUMBER(38,0), 
	"SCHEMA_ID_FK" NUMBER(38,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"OBJECT_ID" NUMBER(38,0), 
	"SCHEMA_ID" NUMBER(38,0), 
	"TYPE" CHAR(2 CHAR)
   ) ON COMMIT PRESERVE ROWS ;
