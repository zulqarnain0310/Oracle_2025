--------------------------------------------------------
--  DDL for Trigger TT_TR_OAOLMASTERUPLOADDATA_
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA_" BEFORE INSERT 
   ON tt_OAOLMasterUploadData
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_OAOLMasterUploadData_.NEXTVAL INTO :NEW.EntityId
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA_" ENABLE;
