--------------------------------------------------------
--  DDL for Trigger TT_TR_PARENTID_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_PARENTID_ID" BEFORE INSERT 
   ON tt_ParentID
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_ParentID_ID.NEXTVAL INTO :NEW.ID
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_PARENTID_ID" ENABLE;
