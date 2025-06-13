--------------------------------------------------------
--  Ref Constraints for Table MD_USER_DEFINED_DATA_TYPES
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_USER_DEFINED_DATA_TYPES" ADD CONSTRAINT "MD_USER_DEFINED_DATA_TYPE_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
