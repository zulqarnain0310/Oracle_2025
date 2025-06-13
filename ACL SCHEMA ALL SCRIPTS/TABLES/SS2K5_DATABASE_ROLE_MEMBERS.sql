--------------------------------------------------------
--  DDL for Table SS2K5_DATABASE_ROLE_MEMBERS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."SS2K5_DATABASE_ROLE_MEMBERS" 
   (	"DB_ID" NUMBER(10,0), 
	"MEMBER_PRINCIPAL_ID" NUMBER(10,0), 
	"ROLE_PRINCIPAL_ID" NUMBER(10,0)
   ) ON COMMIT PRESERVE ROWS ;
