--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_FN_KEYS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."STAGE_SS2K5_FN_KEYS" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"OBJECT_ID_GEN" NUMBER(38,0), 
	"NAME" VARCHAR2(256 CHAR), 
	"OBJECT_ID" NUMBER(38,0)
   ) ON COMMIT PRESERVE ROWS ;
