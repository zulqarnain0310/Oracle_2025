--------------------------------------------------------
--  DDL for Trigger TT_TR_OAOLMASTERUPLOADDATA__6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__6" BEFORE INSERT 
   ON tt_OAOLMasterUploadData_6
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_OAOLMasterUploadData__6.NEXTVAL INTO :NEW.EntityId
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__6" ENABLE;
