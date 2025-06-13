--------------------------------------------------------
--  DDL for Trigger TDATA_GENINDICESKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."TDATA_GENINDICESKEYTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_INDICES
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENINDICESKEYTRIG;

/
ALTER TRIGGER "RBL_TEMPDB"."TDATA_GENINDICESKEYTRIG" ENABLE;
