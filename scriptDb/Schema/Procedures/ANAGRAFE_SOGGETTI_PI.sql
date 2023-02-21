CREATE OR REPLACE procedure ANAGRAFE_SOGGETTI_PI
/******************************************************************************
 NOME:        ANAGRAFE_SOGGETTI_PI
 DESCRIZIONE: Procedure for Check REFERENTIAL Integrity
                         at INSERT on Table ANAGRAFE_SOGGETTI
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:  -20002, Non esiste riferimento su TABLE
             -20008, Numero di CHILD assegnato a TABLE non ammesso
 ANNOTAZIONI: Richiamata da Trigger ANAGRAFE_SOGGETTI_TIU
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
                        Generata in automatico.
******************************************************************************/
(new_provincia_nas IN number,
 new_comune_nas IN number,
 new_provincia_res IN number,
 new_comune_res IN number,
 new_provincia_dom IN number,
 new_comune_dom IN number,
 new_tipo_soggetto IN varchar)
is
   integrity_error  exception;
   errno            integer;
   errmsg           char(200);
   dummy            integer;
   found            boolean;
   cardinality      integer;
   mutating         exception;
   PRAGMA exception_init(mutating, -4091);
   --  Dichiarazione di InsertChildParentExist per la tabella padre "AD4_COMUNI"
   cursor cpk1_anagrafe_soggetti(var_provincia_dom number,
                                 var_comune_dom number) is
      select 1
      from   AD4_COMUNI
      where  PROVINCIA_STATO = var_provincia_dom
       and   COMUNE = var_comune_dom
       and   var_provincia_dom is not null
       and   var_provincia_dom > 0
       and   var_comune_dom is not null;
   --  Dichiarazione di InsertChildParentExist per la tabella padre "AD4_COMUNI"
   cursor cpk2_anagrafe_soggetti(var_provincia_res number,
                                 var_comune_res number) is
      select 1
      from   AD4_COMUNI
      where  PROVINCIA_STATO = var_provincia_res
       and   COMUNE = var_comune_res
       and   var_provincia_res is not null
       and   var_provincia_res > 0
       and   var_comune_res is not null;
   --  Dichiarazione di InsertChildParentExist per la tabella padre "AD4_COMUNI"
   cursor cpk3_anagrafe_soggetti(var_provincia_nas number,
                                 var_comune_nas number) is
      select 1
      from   AD4_COMUNI
      where  PROVINCIA_STATO = var_provincia_nas
       and   COMUNE = var_comune_nas
       and   var_provincia_nas is not null
       and   var_provincia_nas > 0
       and   var_comune_nas is not null;
   --  Dichiarazione di InsertChildParentExist per la tabella padre "TIPI_SOGGETTO"
   cursor cpk4_anagrafe_soggetti(var_tipo_soggetto varchar) is
      select 1
      from   TIPI_SOGGETTO
      where  TIPO_SOGGETTO = var_tipo_soggetto
       and   var_tipo_soggetto is not null;
begin
   begin  -- Check REFERENTIAL Integrity
      begin  --  Parent "AD4_COMUNI" deve esistere quando si inserisce su "ANAGRAFE_SOGGETTI"
         if NEW_PROVINCIA_DOM is not null and new_provincia_dom > 0 and
            NEW_COMUNE_DOM is not null then
            open  cpk1_anagrafe_soggetti(NEW_PROVINCIA_DOM,
                                         NEW_COMUNE_DOM);
            fetch cpk1_anagrafe_soggetti into dummy;
            found := cpk1_anagrafe_soggetti%FOUND;
            close cpk1_anagrafe_soggetti;
            if not found then
               errno  := -20002;
               errmsg := 'Non esiste riferimento su Comuni. La registrazione Anagrafe Soggetti non puo'' essere inserita.';
               raise integrity_error;
            end if;
         end if;
      exception
         when MUTATING then null;  -- Ignora Check su Relazioni Ricorsive
      end;
      begin  --  Parent "AD4_COMUNI" deve esistere quando si inserisce su "ANAGRAFE_SOGGETTI"
         if NEW_PROVINCIA_RES is not null and new_provincia_res > 0 and
            NEW_COMUNE_RES is not null then
            open  cpk2_anagrafe_soggetti(NEW_PROVINCIA_RES,
                                         NEW_COMUNE_RES);
            fetch cpk2_anagrafe_soggetti into dummy;
            found := cpk2_anagrafe_soggetti%FOUND;
            close cpk2_anagrafe_soggetti;
            if not found then
               errno  := -20002;
               errmsg := 'Non esiste riferimento su Comuni. La registrazione Anagrafe Soggetti non puo'' essere inserita.';
               raise integrity_error;
            end if;
         end if;
      exception
         when MUTATING then null;  -- Ignora Check su Relazioni Ricorsive
      end;
      begin  --  Parent "AD4_COMUNI" deve esistere quando si inserisce su "ANAGRAFE_SOGGETTI"
         if NEW_PROVINCIA_NAS is not null and new_provincia_nas > 0 and
            NEW_COMUNE_NAS is not null then
            open  cpk3_anagrafe_soggetti(NEW_PROVINCIA_NAS,
                                         NEW_COMUNE_NAS);
            fetch cpk3_anagrafe_soggetti into dummy;
            found := cpk3_anagrafe_soggetti%FOUND;
            close cpk3_anagrafe_soggetti;
            if not found then
               errno  := -20002;
               errmsg := 'Non esiste riferimento su Comuni. La registrazione Anagrafe Soggetti non puo'' essere inserita.';
               raise integrity_error;
            end if;
         end if;
      exception
         when MUTATING then null;  -- Ignora Check su Relazioni Ricorsive
      end;
      begin  --  Parent "TIPI_SOGGETTO" deve esistere quando si inserisce su "ANAGRAFE_SOGGETTI"
         if NEW_TIPO_SOGGETTO is not null then
            open  cpk4_anagrafe_soggetti(NEW_TIPO_SOGGETTO);
            fetch cpk4_anagrafe_soggetti into dummy;
            found := cpk4_anagrafe_soggetti%FOUND;
            close cpk4_anagrafe_soggetti;
            if not found then
               errno  := -20002;
               errmsg := 'Non esiste riferimento su Tipi soggetto. La registrazione Anagrafe Soggetti non puo'' essere inserita.';
               raise integrity_error;
            end if;
         end if;
      exception
         when MUTATING then null;  -- Ignora Check su Relazioni Ricorsive
      end;
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

