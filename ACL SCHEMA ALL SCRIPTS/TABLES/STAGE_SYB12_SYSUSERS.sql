--------------------------------------------------------
--  DDL for Table STAGE_SYB12_SYSUSERS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."STAGE_SYB12_SYSUSERS" 
   (	"SVRID_FK" NUMBER, 
	"DBID_GEN_FK" NUMBER, 
	"SUID_GEN" NUMBER, 
	"GEN_ID_FK" NUMBER, 
	"SUID" NUMBER, 
	"DB_UID" NUMBER, 
	"GID" NUMBER, 
	"NAME" VARCHAR2(256 BYTE), 
	"ENVIRON" VARCHAR2(256 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
