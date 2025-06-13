--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_OBJECTS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_SS2K5_OBJECTS" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"OBJID_GEN" NUMBER(38,0), 
	"SCHEMA_ID" NUMBER(38,0), 
	"OBJECT_ID" NUMBER(38,0), 
	"NAME" VARCHAR2(256 CHAR), 
	"TYPE" CHAR(2 CHAR), 
	"PARENT_OBJECT_ID" NUMBER(38,0), 
	"IS_MS_SHIPPED" NUMBER(1,0)
   ) ON COMMIT PRESERVE ROWS ;
