CREATE OR REPLACE TRIGGER "DR$ANAG_DENOM_RICERCA_CTXTC" after insert or update on "AS4"."ANAGRAFICI" for each row
declare   reindex boolean := FALSE;   updop   boolean := FALSE; begin   ctxsys.drvdml.c_updtab.delete;   ctxsys.drvdml.c_numtab.delete;   ctxsys.drvdml.c_vctab.delete;   ctxsys.drvdml.c_rowid := :new.rowid;   if (inserting or updating('DENOMINAZIONE_RICERCA') or       :new."DENOMINAZIONE_RICERCA" <> :old."DENOMINAZIONE_RICERCA") then     reindex := TRUE;     updop := (not inserting);     ctxsys.drvdml.c_text_vc2 := :new."DENOMINAZIONE_RICERCA";   end if;   ctxsys.drvdml.ctxcat_dml('AS4','ANAG_DENOM_RICERCA_CTX', reindex, updop); end;
/


