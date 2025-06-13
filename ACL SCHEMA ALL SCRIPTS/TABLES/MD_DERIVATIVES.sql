--------------------------------------------------------
--  DDL for Table MD_DERIVATIVES
--------------------------------------------------------

  CREATE TABLE "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES" 
   (	"ID" NUMBER, 
	"SRC_ID" NUMBER, 
	"SRC_TYPE" VARCHAR2(4000 BYTE), 
	"DERIVED_ID" NUMBER, 
	"DERIVED_TYPE" VARCHAR2(4000 BYTE), 
	"DERIVED_CONNECTION_ID_FK" NUMBER, 
	"TRANSFORMED" CHAR(1 BYTE), 
	"ORIGINAL_IDENTIFIER" VARCHAR2(4000 BYTE), 
	"NEW_IDENTIFIER" VARCHAR2(4000 BYTE), 
	"DERIVED_OBJECT_NAMESPACE" VARCHAR2(40 BYTE), 
	"DERIVATIVE_REASON" VARCHAR2(10 BYTE), 
	"SECURITY_GROUP_ID" NUMBER DEFAULT 0, 
	"CREATED_ON" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(255 BYTE), 
	"LAST_UPDATED_ON" DATE, 
	"LAST_UPDATED_BY" VARCHAR2(255 BYTE), 
	"ENABLED" CHAR(1 BYTE) DEFAULT 'Y'
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;

   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES"."TRANSFORMED" IS 'Set this field to ''Y'' if we carry out any sort of transformation on teh derived object.';
   COMMENT ON TABLE "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES"  IS 'This table is used to store objects that are derived from each other.  For example in a migration an auto-increment column in a source model could be mapped to a primary key, and a sequence, and a trigger.  The MD_DERIVATIVES table would store the fact that these 3 objects are derived from the auto-increment column.';
