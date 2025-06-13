--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_DATABASES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."STAGE_SS2K5_DATABASES" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN" NUMBER(38,0), 
	"NAME" VARCHAR2(256 CHAR), 
	"DATABASE_ID" NUMBER(38,0)
   ) ON COMMIT PRESERVE ROWS ;
