--------------------------------------------------------
--  Ref Constraints for Table DEPT
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DEPT" ADD CONSTRAINT "FK__DEPT__ID__74C8275F" FOREIGN KEY ("ID")
	  REFERENCES "RBL_MISDB_PROD"."EMP" ("ID") ENABLE;
