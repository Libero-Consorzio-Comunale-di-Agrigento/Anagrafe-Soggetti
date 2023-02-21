CREATE OR REPLACE procedure ANAGRAFE_SOGGETTI_PD
/******************************************************************************
 NOME:        ANAGRAFE_SOGGETTI_PD
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at DELETE on Table ANAGRAFE_SOGGETTI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20006, Esistono riferimenti su CHILD TABLE
 ANNOTAZIONI: Richiamata da Trigger ANAGRAFE_SOGGETTI_TD
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
    0 07/09/2005 MM     Introduzione controllo di integrita referenziale su
                       XX4_ANAGRAFE_SOGGETTI.
******************************************************************************/
(old_ni IN number,
 old_dal IN date)
is
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   dummy            integer;
   found            boolean;
   oggetto          varchar2(200);
   --  Declaration of DeleteParentRestrict constraint for "XX4_ANAGRAFE_SOGGETTI"
   cursor cfk1_anagrafe_soggetti(var_ni number, var_dal date) is
      select oggetto
      from   XX4_ANAGRAFE_SOGGETTI
      where  ni = var_ni
       and   dal = var_dal
       and   var_ni is not null
       and   var_dal is not null
     UNION
      select oggetto
      from   XX4_ANAGRAFE_SOGGETTI
      where  ni = var_ni
       and   var_ni is not null
       and   var_dal is null; -- se dal e' nullo nessuna registrazione e' eliminabile
begin
   begin  -- Check REFERENTIAL Integrity
      --  Cannot delete parent "ANAGRAFE_SOGGETTI" if children still exist in "XX4_ANAGRAFE_SOGGETTI"
      open  cfk1_anagrafe_soggetti(OLD_NI,OLD_DAL);
      fetch cfk1_anagrafe_soggetti into oggetto;
      found := cfk1_anagrafe_soggetti%FOUND;
      close cfk1_anagrafe_soggetti;
      if found then
          errno  := -20006;
          errmsg := 'Esistono riferimenti su Anagrafe Soggetti ('||oggetto||'). La registrazione non e'' modificabile.';
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

