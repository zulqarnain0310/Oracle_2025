--------------------------------------------------------
--  Ref Constraints for Table MD_OTHER_OBJECTS
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."MD_OTHER_OBJECTS" ADD CONSTRAINT "MD_OTHER_OBJECTS_MD_SCHEM_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "RBL_MISDB_PROD"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
