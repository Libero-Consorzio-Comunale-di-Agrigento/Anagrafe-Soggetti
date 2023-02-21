CREATE OR REPLACE TRIGGER ANSO_TO_ANAGRAFICI_TD
/******************************************************************************
       NOME:        ANSO_TO_ANAGRAFICI_TID
       DESCRIZIONE: Trigger for allineamento fra ANAGRAFE_SOGGETTI e ANAGRAFICI
                    Impossibile cancellare record, vanno storicizzati
       ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
       ANNOTAZIONI:
       REVISIONI:
       Rev. Data       Autore Descrizione
       ---- ---------- ------ ------------------------------------------------------
                              Prima Emissione
          1 06/09/2018 SNeg   Impossibile cancellare
      ******************************************************************************/
   INSTEAD OF DELETE
   ON ANAGRAFE_SOGGETTI    FOR EACH ROW
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
          
               RAISE_APPLICATION_ERROR(-20999, si4.get_error('A10014')
--               'Eliminazione non consentita!'
               );
         end;
         IntegrityPackage.PreviousNestLevel;
      end if;
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


