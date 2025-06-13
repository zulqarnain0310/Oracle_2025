--------------------------------------------------------
--  DDL for Table MD_GROUPS
--------------------------------------------------------

  CREATE TABLE "RBL_TEMPDB"."MD_GROUPS" 
   (	"ID" NUMBER, 
	"SCHEMA_ID_FK" NUMBER, 
	"GROUP_NAME" VARCHAR2(4000 BYTE), 
	"GROUP_FLAG" CHAR(1 BYTE), 
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

   COMMENT ON COLUMN "RBL_TEMPDB"."MD_GROUPS"."ID" IS 'Primary Key';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_GROUPS"."SCHEMA_ID_FK" IS 'Schema in which this object belongs //PARENTFIELD';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_GROUPS"."GROUP_NAME" IS 'Name of the group //OBJECTNAME';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_GROUPS"."GROUP_FLAG" IS 'This is a flag to signify a group or a role.  If this is ''R'' it means the group is known as a Role.  Any other value means it is known as a group.';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_GROUPS"."NATIVE_SQL" IS 'SQL Used to generate this object at source';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_GROUPS"."NATIVE_KEY" IS 'Unique id for this object at source';
   COMMENT ON TABLE "RBL_TEMPDB"."MD_GROUPS"  IS 'Groups of users in a schema';
