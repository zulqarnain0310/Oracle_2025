--------------------------------------------------------
--  Ref Constraints for Table MD_CATALOGS
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."MD_CATALOGS" ADD CONSTRAINT "MD_CATALOGS_MD_CONNECTION_FK1" FOREIGN KEY ("CONNECTION_ID_FK")
	  REFERENCES "RBL_MISDB_PROD"."MD_CONNECTIONS" ("ID") ON DELETE CASCADE ENABLE;
