--------------------------------------------------------
--  DDL for Table SS2K5_DATABASE_ROLE_MEMBERS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SS2K5_DATABASE_ROLE_MEMBERS" 
   (	"DB_ID" NUMBER(10,0), 
	"MEMBER_PRINCIPAL_ID" NUMBER(10,0), 
	"ROLE_PRINCIPAL_ID" NUMBER(10,0)
   ) ON COMMIT PRESERVE ROWS ;
