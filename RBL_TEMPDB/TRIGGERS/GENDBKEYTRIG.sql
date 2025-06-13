--------------------------------------------------------
--  DDL for Trigger GENDBKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."GENDBKEYTRIG" 
					BEFORE INSERT ON stage_syb12_sysdatabases 
					FOR EACH ROW 
					BEGIN
					  IF :new.dbid_gen is null THEN
					     :new.dbid_gen := MD_META.get_next_id;
					  END IF;
					END GenDbKeyTrig;

/
ALTER TRIGGER "RBL_TEMPDB"."GENDBKEYTRIG" ENABLE;
