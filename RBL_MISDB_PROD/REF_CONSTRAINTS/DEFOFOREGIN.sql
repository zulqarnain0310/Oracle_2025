--------------------------------------------------------
--  Ref Constraints for Table DEFOFOREGIN
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DEFOFOREGIN" ADD CONSTRAINT "FK__DEFOFOREGIN__AGE__5EB8EAAF" FOREIGN KEY ("ROLLNO")
	  REFERENCES "RBL_MISDB_PROD"."DEMO" ("ID") ENABLE;
