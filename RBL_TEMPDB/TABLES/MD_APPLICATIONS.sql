--------------------------------------------------------
--  DDL for Table MD_APPLICATIONS
--------------------------------------------------------

  CREATE TABLE "RBL_TEMPDB"."MD_APPLICATIONS" 
   (	"ID" NUMBER, 
	"NAME" VARCHAR2(4000 BYTE), 
	"DESCRIPTION" VARCHAR2(4000 BYTE), 
	"BASE_DIR" VARCHAR2(4000 BYTE), 
	"OUTPUT_DIR" VARCHAR2(4000 BYTE), 
	"BACKUP_DIR" VARCHAR2(4000 BYTE), 
	"INPLACE" NUMBER, 
	"PROJECT_ID_FK" NUMBER, 
	"SECURITY_GROUP_ID" NUMBER DEFAULT 0, 
	"CREATED_ON" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(255 BYTE), 
	"LAST_UPDATED_ON" DATE, 
	"LAST_UPDATED_BY" VARCHAR2(255 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;

   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."ID" IS 'Primary Key';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."NAME" IS 'Name of the application suite  //OBJECTNAME';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."DESCRIPTION" IS 'Overview of what the application does.';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."BASE_DIR" IS 'This is the base src directory for the application.  It could be an svn checkout, a clearcase view or something similar';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."OUTPUT_DIR" IS 'This is the output directory where the scanner will present the converted files, if there are converted or modified.';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."BACKUP_DIR" IS 'This is the directory in which the application files are backed up if a backp is chosen';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."INPLACE" IS 'Designates whether the changes have been made inplace, in the source directory or not';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_APPLICATIONS"."PROJECT_ID_FK" IS 'project of the database(s) this application relates to';
   COMMENT ON TABLE "RBL_TEMPDB"."MD_APPLICATIONS"  IS 'This is the base table for application projects.  It holds the base information for applications associated with a database';
