CREATE OR REPLACE TRIGGER KEY_ERROR_LOG_TIU
/******************************************************************************
 NOME:        KEY_ERROR_LOG_TIU
 DESCRIZIONE: Trigger for Set DATA Integrity
                          Set FUNCTIONAL Integrity
                       on Table KEY_ERROR_LOG
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
    0 30/01/2004 MM     Creazione.
    1 21/04/2006 MM     Recupero dell'id da associare al record tramite sequence
                        KEEL_SQ invece che tramite si4.next_id.
******************************************************************************/
   before INSERT or UPDATE on KEY_ERROR_LOG
for each row
declare
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   found            boolean;
begin
   begin  -- Set DATA Integrity
      /* NONE */ null;
   end;
  begin  -- Set FUNCTIONAL Integrity
      if IntegrityPackage.GetNestLevel = 0 then
         IntegrityPackage.NextNestLevel;
         begin  -- Global FUNCTIONAL Integrity at Level 0
            /* NONE */ null;
         end;
         IntegrityPackage.PreviousNestLevel;
      end if;
      IntegrityPackage.NextNestLevel;
      begin  -- Full FUNCTIONAL Integrity at Any Level
         if :NEW.ERROR_ID IS NULL THEN
            select keel_sq.nextval
              into :NEW.ERROR_ID
              from dual;
         end if;
      end;
      IntegrityPackage.PreviousNestLevel;
   end;
exception
   when integrity_error then
        IntegrityPackage.InitNestLevel;
        raise_application_error(errno, errmsg);
   when others then
        IntegrityPackage.InitNestLevel;
        raise;
end;
/


