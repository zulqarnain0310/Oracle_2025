--------------------------------------------------------
--  DDL for Trigger GENSCHEMAKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."GENSCHEMAKEYTRIG" 
					BEFORE INSERT ON stage_syb12_sysusers
					FOR EACH ROW 
					BEGIN
					  IF :new.suid_gen is null THEN
					     :new.suid_gen := MD_META.get_next_id;
					  END IF;
					END GenSchemaKeyTrig;

/
ALTER TRIGGER "RBL_TEMPDB"."GENSCHEMAKEYTRIG" ENABLE;
