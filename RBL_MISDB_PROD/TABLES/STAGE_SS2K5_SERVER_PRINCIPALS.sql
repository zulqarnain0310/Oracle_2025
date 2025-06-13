--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_SERVER_PRINCIPALS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."STAGE_SS2K5_SERVER_PRINCIPALS" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"DB_ID" NUMBER(38,0), 
	"NAME" VARCHAR2(256 CHAR), 
	"SID" RAW(85), 
	"TYPE" CHAR(2 CHAR)
   ) ON COMMIT PRESERVE ROWS ;
