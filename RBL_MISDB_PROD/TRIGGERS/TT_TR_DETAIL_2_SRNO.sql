--------------------------------------------------------
--  DDL for Trigger TT_TR_DETAIL_2_SRNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_DETAIL_2_SRNO" BEFORE INSERT 
   ON tt_Detail_2
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_Detail_2_SrNo.NEXTVAL INTO :NEW.SrNo
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_DETAIL_2_SRNO" ENABLE;
