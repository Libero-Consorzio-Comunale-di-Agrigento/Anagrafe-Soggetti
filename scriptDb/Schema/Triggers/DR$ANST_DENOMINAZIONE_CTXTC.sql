CREATE OR REPLACE TRIGGER "DR$ANST_DENOMINAZIONE_CTXTC" after insert or update on "AS4"."ANAGRAFE_SOGGETTI_TABLE" for each row
declare   reindex boolean := FALSE;   updop   boolean := FALSE; begin   ctxsys.drvdml.c_updtab.delete;   ctxsys.drvdml.c_numtab.delete;   ctxsys.drvdml.c_vctab.delete;   ctxsys.drvdml.c_rowid := :new.rowid;   if (inserting or updating('DENOMINAZIONE') or       :new."DENOMINAZIONE" <> :old."DENOMINAZIONE") then     reindex := TRUE;     updop := (not inserting);     ctxsys.drvdml.c_text_vc2 := :new."DENOMINAZIONE";   end if;   ctxsys.drvdml.ctxcat_dml('AS4','ANST_DENOMINAZIONE_CTX', reindex, updop); end;
/


