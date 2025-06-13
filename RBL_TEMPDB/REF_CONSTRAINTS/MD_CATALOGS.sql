--------------------------------------------------------
--  Ref Constraints for Table MD_CATALOGS
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_CATALOGS" ADD CONSTRAINT "MD_CATALOGS_MD_CONNECTION_FK1" FOREIGN KEY ("CONNECTION_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_CONNECTIONS" ("ID") ON DELETE CASCADE ENABLE;
