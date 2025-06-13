--------------------------------------------------------
--  DDL for Trigger TT_TR_OAOLMASTERUPLOADDATA__4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__4" BEFORE INSERT 
   ON tt_OAOLMasterUploadData_4
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_OAOLMasterUploadData__4.NEXTVAL INTO :NEW.EntityId
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__4" ENABLE;
