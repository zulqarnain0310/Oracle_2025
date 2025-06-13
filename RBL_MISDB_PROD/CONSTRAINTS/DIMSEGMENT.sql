--------------------------------------------------------
--  Constraints for Table DIMSEGMENT
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMSEGMENT" MODIFY ("EWS_SEGMENT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSEGMENT" MODIFY ("EWS_SEGMENTALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSEGMENT" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
