--------------------------------------------------------
--  DDL for Trigger TDATA_GENCOLUMNKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."TDATA_GENCOLUMNKEYTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_COLUMNS
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENCOLUMNKEYTRIG;

/
ALTER TRIGGER "RBL_TEMPDB"."TDATA_GENCOLUMNKEYTRIG" ENABLE;
