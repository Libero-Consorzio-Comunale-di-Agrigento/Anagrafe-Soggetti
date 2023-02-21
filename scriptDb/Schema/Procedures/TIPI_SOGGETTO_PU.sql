CREATE OR REPLACE procedure TIPI_SOGGETTO_PU
/******************************************************************************
 NOME:        TIPI_SOGGETTO_PU
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at UPDATE on Table TIPI_SOGGETTO
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20001, Informazione COLONNA non modificabile
             -20003, Non esiste riferimento su PARENT TABLE
             -20004, Identificazione di TABLE non modificabile
             -20005, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger TIPI_SOGGETTO_TIU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Generata in automatico.
  1   31/01/2018 SN     Gestione si4.get_error
******************************************************************************/
(old_tipo_soggetto IN varchar,
 new_tipo_soggetto IN varchar)
is
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   dummy            integer;
   found            boolean;
   seq              number;
   mutating         exception;
   PRAGMA exception_init(mutating, -4091);
   --  Declaration of UpdateParentRestrict constraint for "ANAGRAFE_SOGGETTI"
   cursor cfk1_tipi_soggetto(var_tipo_soggetto varchar) is
      select 1
      from   ANAGRAFE_SOGGETTI
      where  TIPO_SOGGETTO = var_tipo_soggetto
       and   var_tipo_soggetto is not null;
begin
   begin  -- Check REFERENTIAL Integrity
      seq := IntegrityPackage.GetNestLevel;
      --  Chiave di "TIPI_SOGGETTO" non modificabile se esistono referenze su "ANAGRAFE_SOGGETTI"
      if (OLD_TIPO_SOGGETTO != NEW_TIPO_SOGGETTO) then
         open  cfk1_tipi_soggetto(OLD_TIPO_SOGGETTO);
         fetch cfk1_tipi_soggetto into dummy;
         found := cfk1_tipi_soggetto%FOUND;
         close cfk1_tipi_soggetto;
         if found then
            errno  := -20005;
            errmsg := si4.get_error('A10063') ||--'Esistono riferimenti su Anagrafe Soggetti'
                    '. La registrazione di Tipi soggetto non e'' modificabile.';
            raise integrity_error;
         end if;
      end if;
      null;
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

