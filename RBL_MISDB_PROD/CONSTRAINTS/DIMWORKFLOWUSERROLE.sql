--------------------------------------------------------
--  Constraints for Table DIMWORKFLOWUSERROLE
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMWORKFLOWUSERROLE" MODIFY ("WORKFLOWUSERROLE_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMWORKFLOWUSERROLE" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
