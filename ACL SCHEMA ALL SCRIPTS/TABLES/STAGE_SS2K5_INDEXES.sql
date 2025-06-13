--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_INDEXES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."STAGE_SS2K5_INDEXES" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"OBJECT_ID_GEN" NUMBER(38,0), 
	"OBJECT_ID" NUMBER(38,0), 
	"INDEX_ID" NUMBER(38,0), 
	"NAME" VARCHAR2(256 CHAR), 
	"IS_UNIQUE" NUMBER(1,0), 
	"IS_PRIMARY_KEY" NUMBER(1,0)
   ) ON COMMIT PRESERVE ROWS ;
