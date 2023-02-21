CREATE OR REPLACE TRIGGER ANAG_TO_ANST_TIU
/******************************************************************************
    NOME:        ANAG_TO_ANST_TIU
                Mantiene allineata la tabella anagrafe_soggetti_table
    DESCRIZIONE: Trigger for Check DATA Integrity
                             Check REFERENTIAL Integrity
                               Set REFERENTIAL Integrity
                               Set FUNCTIONAL Integrity
                          at INSERT or UPDATE on Table ANAGRAFICI
    ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
    ANNOTAZIONI: Richiama Procedure ALLINEA_ANAG_SOGGETTI_TABLE
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
                           Prima distribuzione.
      01 20/02/2019 SNeg   Se aggiornamento da package non allineo immediatamente
      02 26/03/2019 SNeg   Sistemazione controlli se record da allineare sulla tabella Bug #33687
   ******************************************************************************/
   AFTER INSERT OR UPDATE
   ON ANAGRAFICI
   FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   d_result          AFC_Error.t_error_number;
   v_agg_da_pack_on number := anagrafici_pkg.v_aggiornamento_da_package_on;
BEGIN
--dbms_output.put_line(   nvl(:old.ID_ANAGRAFICA        ,'1') ||'!='|| nvl(:new.ID_ANAGRAFICA        ,'1')
--||' & ' || nvl(:old.NI                   ,'1') ||'!='|| nvl(:new.NI                   ,'1')
--||' & ' || nvl(:old.DAL                  ,trunc(sysdate)) ||'!='|| nvl(:new.DAL                  ,trunc(sysdate))
--||' & ' || nvl(:old.AL                   ,trunc(sysdate)) ||'!='|| nvl(:new.AL                   ,trunc(sysdate))
--||' & ' || nvl(:old.COGNOME              ,'1') ||'!='|| nvl(:new.COGNOME              ,'1')
--||' & ' || nvl(:old.NOME                 ,'1') ||'!='|| nvl(:new.NOME                 ,'1')
--||' & ' || nvl(:old.SESSO                ,'1') ||'!='|| nvl(:new.SESSO                ,'1')
--||' & ' || nvl(:old.DATA_NAS             ,trunc(sysdate)) ||'!='|| nvl(:new.DATA_NAS             ,trunc(sysdate))
--||' & ' || nvl(:old.PROVINCIA_NAS        ,'1') ||'!='|| nvl(:new.PROVINCIA_NAS        ,'1')
--||' & ' || nvl(:old.COMUNE_NAS           ,'1') ||'!='|| nvl(:new.COMUNE_NAS           ,'1')
--||' & ' || nvl(:old.LUOGO_NAS            ,'1') ||'!='|| nvl(:new.LUOGO_NAS            ,'1')
--||' & ' || nvl(:old.CODICE_FISCALE       ,'1') ||'!='|| nvl(:new.CODICE_FISCALE       ,'1')
--||' & ' || nvl(:old.CODICE_FISCALE_ESTERO,'1') ||'!='|| nvl(:new.CODICE_FISCALE_ESTERO,'1')
--||' & ' || nvl(:old.PARTITA_IVA          ,'1') ||'!='|| nvl(:new.PARTITA_IVA          ,'1')
--||' & ' || nvl(:old.CITTADINANZA         ,'1') ||'!='|| nvl(:new.CITTADINANZA         ,'1')
--||' & ' || nvl(:old.GRUPPO_LING          ,'1') ||'!='|| nvl(:new.GRUPPO_LING          ,'1')
--||' & ' || nvl(:old.COMPETENZA           ,'1') ||'!='|| nvl(:new.COMPETENZA           ,'1')
--||' & ' || nvl(:old.COMPETENZA_ESCLUSIVA ,'1') ||'!='|| nvl(:new.COMPETENZA_ESCLUSIVA ,'1')
--||' & ' || nvl(:old.TIPO_SOGGETTO        ,'1') ||'!='|| nvl(:new.TIPO_SOGGETTO        ,'1')
--||' & ' || nvl(:old.STATO_CEE            ,'1') ||'!='|| nvl(:new.STATO_CEE            ,'1')
--||' & ' || nvl(:old.PARTITA_IVA_CEE      ,'1') ||'!='|| nvl(:new.PARTITA_IVA_CEE      ,'1')
--||' & ' || nvl(:old.FINE_VALIDITA        ,trunc(sysdate)) ||'!='|| nvl(:new.FINE_VALIDITA        ,trunc(sysdate))
--||' & ' || nvl(:old.STATO_SOGGETTO       ,'1') ||'!='|| nvl(:new.STATO_SOGGETTO       ,'1')
--||' & ' || nvl(:old.DENOMINAZIONE        ,'1') ||'!='|| nvl(:new.DENOMINAZIONE        ,'1')
--||' & ' || nvl(:old.NOTE                 ,'1') ||'!='|| nvl(:new.NOTE                 ,'1')
--||' & ' || nvl(:old.VERSION              ,'1') ||'!='|| nvl(:new.VERSION              ,'1')
--||' & ' || nvl(:old.UTENTE               ,'1') ||'!='|| nvl(:new.UTENTE               ,'1')
--||' & ' || nvl(:old.DATA_AGG             ,trunc(sysdate)) ||'!='|| nvl(:new.DATA_AGG             ,trunc(sysdate)));

 if Integritypackage.GetNestLevel = 0 then -- solo se primo livello
 if ((updating --rev.2 inizio
    and (nvl(:old.ID_ANAGRAFICA        ,'1') != nvl(:new.ID_ANAGRAFICA        ,'1')
    or nvl(:old.NI                   ,'1') != nvl(:new.NI                   ,'1')
    or nvl(:old.DAL                  ,trunc(sysdate + 100)) != nvl(:new.DAL                  ,trunc(sysdate + 100))
    or nvl(:old.AL                   ,trunc(sysdate + 100)) != nvl(:new.AL                   ,trunc(sysdate + 100))
    or nvl(:old.COGNOME              ,'1') != nvl(:new.COGNOME              ,'1')
    or nvl(:old.NOME                 ,'1') != nvl(:new.NOME                 ,'1')
    or nvl(:old.SESSO                ,'1') != nvl(:new.SESSO                ,'1')
    or nvl(:old.DATA_NAS             ,trunc(sysdate + 100)) != nvl(:new.DATA_NAS             ,trunc(sysdate + 100))
    or nvl(:old.PROVINCIA_NAS        ,'1') != nvl(:new.PROVINCIA_NAS        ,'1')
    or nvl(:old.COMUNE_NAS           ,'1') != nvl(:new.COMUNE_NAS           ,'1')
    or nvl(:old.LUOGO_NAS            ,'1') != nvl(:new.LUOGO_NAS            ,'1')
    or nvl(:old.CODICE_FISCALE       ,'1') != nvl(:new.CODICE_FISCALE       ,'1')
    or nvl(:old.CODICE_FISCALE_ESTERO,'1') != nvl(:new.CODICE_FISCALE_ESTERO,'1')
    or nvl(:old.PARTITA_IVA          ,'1') != nvl(:new.PARTITA_IVA          ,'1')
    or nvl(:old.CITTADINANZA         ,'1') != nvl(:new.CITTADINANZA         ,'1')
    or nvl(:old.GRUPPO_LING          ,'1') != nvl(:new.GRUPPO_LING          ,'1')
    or nvl(:old.COMPETENZA           ,'1') != nvl(:new.COMPETENZA           ,'1')
    or nvl(:old.COMPETENZA_ESCLUSIVA ,'1') != nvl(:new.COMPETENZA_ESCLUSIVA ,'1')
    or nvl(:old.TIPO_SOGGETTO        ,'1') != nvl(:new.TIPO_SOGGETTO        ,'1')
    or nvl(:old.STATO_CEE            ,'1') != nvl(:new.STATO_CEE            ,'1')
    or nvl(:old.PARTITA_IVA_CEE      ,'1') != nvl(:new.PARTITA_IVA_CEE      ,'1')
    or nvl(:old.FINE_VALIDITA        ,trunc(sysdate + 100)) != nvl(:new.FINE_VALIDITA        ,trunc(sysdate + 100))
    or nvl(:old.STATO_SOGGETTO       ,'1') != nvl(:new.STATO_SOGGETTO       ,'1')
    or nvl(:old.DENOMINAZIONE        ,'1') != nvl(:new.DENOMINAZIONE        ,'1')
    or nvl(:old.NOTE                 ,'1') != nvl(:new.NOTE                 ,'1')
    or nvl(:old.VERSION              ,'1') != nvl(:new.VERSION              ,'1')
    or nvl(:old.UTENTE               ,'1') != nvl(:new.UTENTE               ,'1')
    or nvl(:old.DATA_AGG             ,trunc(sysdate + 100)) != nvl(:new.DATA_AGG             ,trunc(sysdate + 100))))
    -- rev.2 fine
or NOT updating)
and anagrafici_pkg.v_aggiornamento_da_package_on = 0
then
   DECLARE
      a_istruzione   VARCHAR2 (2000);
      a_messaggio    VARCHAR2 (2000);
   BEGIN
      a_messaggio := '';
      a_istruzione :=
         'begin ALLINEA_ANAG_SOGGETTI_TABLE (' || :NEW.ni || '); end;';
      integritypackage.set_postevent (a_istruzione, a_messaggio);
   EXCEPTION
      WHEN OTHERS
      THEN
         integritypackage.initnestlevel;
         RAISE;
   END;
   end if; -- solo se primo livello
    insert into ALLINEA_ANAG_SOGGETTI_TAB tab
    select :new.ni from dual
      where not exists (select 1
                          from ALLINEA_ANAG_SOGGETTI_TAB
                         where ni = :new.ni);
end if;
EXCEPTION
   WHEN integrity_error
   THEN
      integritypackage.initnestlevel;
      raise_application_error (errno, errmsg);
   WHEN OTHERS
   THEN
      integritypackage.initnestlevel;
      RAISE;
END;
/


