--------------------------------------------------------
--  DDL for Table MD_ADDITIONAL_PROPERTIES
--------------------------------------------------------

  CREATE TABLE "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES" 
   (	"ID" NUMBER, 
	"CONNECTION_ID_FK" NUMBER, 
	"REF_ID_FK" NUMBER, 
	"REF_TYPE" VARCHAR2(4000 BYTE), 
	"PROPERTY_ORDER" NUMBER, 
	"PROP_KEY" VARCHAR2(4000 BYTE), 
	"VALUE" VARCHAR2(4000 BYTE), 
	"SECURITY_GROUP_ID" NUMBER DEFAULT 0, 
	"CREATED_ON" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(255 BYTE), 
	"LAST_UPDATED_ON" DATE, 
	"LAST_UPDATED_BY" VARCHAR2(255 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;

   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"."ID" IS 'Primary Key';
   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"."CONNECTION_ID_FK" IS 'Connection to which this belongs //PARENTFIELD';
   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"."REF_ID_FK" IS 'The object to which this property blongs';
   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"."REF_TYPE" IS 'Type of object that this property belongs to';
   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"."PROPERTY_ORDER" IS 'This is to handle a situation where multiple properties have a relevant order, or multiple properties have multiple values';
   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"."PROP_KEY" IS 'The keyname for this property';
   COMMENT ON COLUMN "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"."VALUE" IS 'The value for this property';
   COMMENT ON TABLE "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES"  IS 'This table is used to store additional properties in key-value pairs.  It is designed to store "other information" that is not supported in the main database object table.';
