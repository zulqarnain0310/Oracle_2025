--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_DB_ROLE_MEMBERS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."STAGE_SS2K5_DB_ROLE_MEMBERS" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"MEMBER_PRINCIPAL_ID" NUMBER(38,0), 
	"ROLE_PRINCIPAL_ID" NUMBER(38,0)
   ) ON COMMIT PRESERVE ROWS ;
