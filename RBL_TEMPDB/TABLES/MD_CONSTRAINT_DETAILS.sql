--------------------------------------------------------
--  DDL for Table MD_CONSTRAINT_DETAILS
--------------------------------------------------------

  CREATE TABLE "RBL_TEMPDB"."MD_CONSTRAINT_DETAILS" 
   (	"ID" NUMBER, 
	"REF_FLAG" CHAR(1 BYTE) DEFAULT 'N', 
	"CONSTRAINT_ID_FK" NUMBER, 
	"COLUMN_ID_FK" NUMBER, 
	"COLUMN_PORTION" NUMBER, 
	"CONSTRAINT_TEXT" CLOB, 
	"DETAIL_ORDER" NUMBER, 
	"SECURITY_GROUP_ID" NUMBER DEFAULT 0, 
	"CREATED_ON" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(255 BYTE), 
	"LAST_UPDATED_ON" DATE, 
	"LAST_UPDATED_BY" VARCHAR2(255 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" 
 LOB ("CONSTRAINT_TEXT") STORE AS BASICFILE (
  TABLESPACE "USERS" ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  CACHE READS LOGGING ) ;

   COMMENT ON COLUMN "RBL_TEMPDB"."MD_CONSTRAINT_DETAILS"."ID" IS 'Primary Key';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_CONSTRAINT_DETAILS"."REF_FLAG" IS '"N" or Null signify that this column is the colum that is used in the constraint.  A flag of Y signifies that the colum is a referenced column (i.e. part of a foreign key constraint)';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_CONSTRAINT_DETAILS"."CONSTRAINT_ID_FK" IS 'Constraint that this detail belongs to //PARENTFIELD';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_CONSTRAINT_DETAILS"."COLUMN_PORTION" IS 'The portion of a column this detail belongs (e.g. for constrints on substrings)';
   COMMENT ON COLUMN "RBL_TEMPDB"."MD_CONSTRAINT_DETAILS"."CONSTRAINT_TEXT" IS 'The text of the constraint';
   COMMENT ON TABLE "RBL_TEMPDB"."MD_CONSTRAINT_DETAILS"  IS 'Constraint details show what columns are "involved" in a constraint.';
