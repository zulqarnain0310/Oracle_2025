--------------------------------------------------------
--  DDL for Table MD_PRIVILEGES
--------------------------------------------------------

  CREATE TABLE "RBL_TEMPDB"."MD_PRIVILEGES" 
   (	"ID" NUMBER, 
	"SCHEMA_ID_FK" NUMBER, 
	"PRIVILEGE_NAME" VARCHAR2(4000 BYTE), 
	"PRIVELEGE_OBJECT_ID" NUMBER, 
	"PRIVELEGEOBJECTTYPE" VARCHAR2(4000 BYTE), 
	"PRIVELEGE_TYPE" VARCHAR2(4000 BYTE), 
	"ADMIN_OPTION" CHAR(1 BYTE), 
	"NATIVE_SQL" CLOB, 
	"NATIVE_KEY" VARCHAR2(4000 BYTE), 
	"COMMENTS" VARCHAR2(4000 BYTE), 
	"SECURITY_GROUP_ID" NUMBER DEFAULT 0, 
	"CREATED_ON" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(255 BYTE), 
	"LAST_UPDATED_ON" DATE, 
	"LAST_UPDATED_BY" VARCHAR2(255 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" 
 LOB ("NATIVE_SQL") STORE AS BASICFILE (
  TABLESPACE "USERS" ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  CACHE READS LOGGING ) ;

   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."ID" IS 'Primary Key';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."SCHEMA_ID_FK" IS 'The schema to which this object belongs //PARENTFIELD';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."PRIVILEGE_NAME" IS 'The name of the privilege //OBJECTNAME';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."PRIVELEGE_OBJECT_ID" IS 'This references the table, view, etc on which the privelege exists.  This can be NULL for things like system wide privileges';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."PRIVELEGEOBJECTTYPE" IS 'The type the privelege is on (e.g. INDEX)';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."PRIVELEGE_TYPE" IS 'e.g.select';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."ADMIN_OPTION" IS 'Flag to show if this was granted with admin option.  ''Y'' means it was granted with admin option ''N'' means it was NOT granted with admin option.  NULL means not applicable (e.g. not known, not supported by source platform, etc.)';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."NATIVE_SQL" IS 'The SQL used to create this privilege at source';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_PRIVILEGES"."NATIVE_KEY" IS 'An identifier for this object at source.';
   COMMENT ON TABLE "RBL_TEMPDB"."MD_PRIVILEGES"  IS 'This table stores privilege information';
