CREATE OR REPLACE TRIGGER CONTATTI_TD
/******************************************************************************
 NOME:        CONTATTI_TD
 DESCRIZIONE: Trigger for Set FUNCTIONAL Integrity
                        Check REFERENTIAL Integrity
                          Set REFERENTIAL Integrity
                       at DELETE on Table CONTATTI
 ANNOTAZIONI: Richiama Procedure CONTATTI_TD
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Generato in automatico.
    1 07/09/2005 MM     Chiamata alla procedure CONTATTI_PD per
                        controllo di integrita referenziale su
                       XX4_CONTATTI.
******************************************************************************/
   before DELETE on CONTATTI
for each row
declare
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   dummy            integer;
   found            boolean;
begin
   begin -- Set FUNCTIONAL Integrity on DELETE
      if IntegrityPackage.GetNestLevel = 0 then
         IntegrityPackage.NextNestLevel;
         begin  -- Global FUNCTIONAL Integrity at Level 0
            IF --:old.al is null or 
               :old.dal <= trunc(sysdate) THEN
               RAISE_APPLICATION_ERROR(-20999, si4.get_error('A10014')
--             'Eliminazione non consentita!'
               );
            END IF;
         end;
         IntegrityPackage.PreviousNestLevel;
      end if;
   end;
   begin  -- Check REFERENTIAL Integrity on DELETE
      -- Child Restrict Table: XX4_CONTATTI
      contatti_pkg.CONTATTI_PD(:OLD.id_contatto, :OLD.DAL, :OLD.AL);
   end;
   begin  -- Set REFERENTIAL Integrity on DELETE
      IntegrityPackage.NextNestLevel;
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


