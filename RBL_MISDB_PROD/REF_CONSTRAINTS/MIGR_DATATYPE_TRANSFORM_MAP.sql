--------------------------------------------------------
--  Ref Constraints for Table MIGR_DATATYPE_TRANSFORM_MAP
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."MIGR_DATATYPE_TRANSFORM_MAP" ADD CONSTRAINT "MIGR_DATATYPE_TRANSFORM_M_FK1" FOREIGN KEY ("PROJECT_ID_FK")
	  REFERENCES "RBL_MISDB_PROD"."MD_PROJECTS" ("ID") ON DELETE CASCADE ENABLE;
