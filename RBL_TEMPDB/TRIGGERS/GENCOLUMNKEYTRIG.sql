--------------------------------------------------------
--  DDL for Trigger GENCOLUMNKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."GENCOLUMNKEYTRIG" 
					BEFORE INSERT ON stage_syb12_syscolumns
					FOR EACH ROW 
					BEGIN
					  IF :new.colid_gen is null THEN
					     :new.colid_gen := MD_META.get_next_id;
					  END IF;
					END GenColumnKeyTrig;

/
ALTER TRIGGER "RBL_TEMPDB"."GENCOLUMNKEYTRIG" ENABLE;
