CREATE OR REPLACE procedure TIPI_SOGGETTO_PD
/******************************************************************************
 NOME:        TIPI_SOGGETTO_PD
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at DELETE on Table TIPI_SOGGETTO
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20006, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger TIPI_SOGGETTO_TD
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Generata in automatico.
  1   31/01/2018 SN     Gestione si4.get_error
******************************************************************************/
(old_tipo_soggetto IN varchar)
is
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   dummy            integer;
   found            boolean;
   --  Declaration of DeleteParentRestrict constraint for "ANAGRAFE_SOGGETTI"
   cursor cfk1_tipi_soggetto(var_tipo_soggetto varchar) is
      select 1
      from   ANAGRAFE_SOGGETTI
      where  TIPO_SOGGETTO = var_tipo_soggetto
       and   var_tipo_soggetto is not null;
begin
   begin  -- Check REFERENTIAL Integrity
      --  Cannot delete parent "TIPI_SOGGETTO" if children still exist in "ANAGRAFE_SOGGETTI"
      open  cfk1_tipi_soggetto(OLD_TIPO_SOGGETTO);
      fetch cfk1_tipi_soggetto into dummy;
      found := cfk1_tipi_soggetto%FOUND;
      close cfk1_tipi_soggetto;
      if found then
         errno  := -20006;
         errmsg :=  si4.get_error('A10063') ||--Esistono riferimenti su Anagrafe Soggetti
         '. La registrazione di Tipi soggetto non e'' eliminabile.';
         raise integrity_error;
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

