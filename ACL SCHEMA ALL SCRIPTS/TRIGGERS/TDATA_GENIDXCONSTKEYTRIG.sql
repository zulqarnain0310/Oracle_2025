--------------------------------------------------------
--  DDL for Trigger TDATA_GENIDXCONSTKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."TDATA_GENIDXCONSTKEYTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_IDXCONSTRAINTS
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENIDXCONSTKEYTRIG;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."TDATA_GENIDXCONSTKEYTRIG" ENABLE;
