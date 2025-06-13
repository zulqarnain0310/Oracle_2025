--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_SYSPROPERTIES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_SS2K5_SYSPROPERTIES" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"CLASS" NUMBER(38,0), 
	"MAJOR_ID" NUMBER(38,0), 
	"MINOR_ID" NUMBER(38,0), 
	"NAME" VARCHAR2(500 CHAR), 
	"VALUE" VARCHAR2(1000 CHAR)
   ) ON COMMIT PRESERVE ROWS ;
