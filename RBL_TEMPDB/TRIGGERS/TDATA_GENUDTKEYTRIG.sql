--------------------------------------------------------
--  DDL for Trigger TDATA_GENUDTKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."TDATA_GENUDTKEYTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_UDTS
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENUDTKEYTRIG;

/
ALTER TRIGGER "RBL_TEMPDB"."TDATA_GENUDTKEYTRIG" ENABLE;
