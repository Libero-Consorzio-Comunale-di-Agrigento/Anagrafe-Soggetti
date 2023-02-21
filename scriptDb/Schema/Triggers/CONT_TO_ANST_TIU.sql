CREATE OR REPLACE TRIGGER CONT_TO_ANST_TIU
/******************************************************************************
    NOME:        CONT_TO_ANST_TIU
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
   ******************************************************************************/
   AFTER INSERT OR UPDATE
   ON CONTATTI
   FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   dummy             INTEGER;
   FOUND             BOOLEAN;
   d_result          AFC_Error.t_error_number;
   v_ni              anagrafici.ni%TYPE;
BEGIN
 if anagrafici_pkg.v_aggiornamento_da_package_on = 0 then
 if Integritypackage.GetNestLevel = 0 then -- solo se primo livello
   SELECT ni
     INTO v_ni
     FROM recapiti
    WHERE id_recapito = NVL (:new.id_recapito, :old.id_recapito);

   DECLARE
      a_istruzione   VARCHAR2 (2000);
      a_messaggio    VARCHAR2 (2000);
   BEGIN
      a_messaggio := '';
      a_istruzione :=
--         'declare v_ni number; begin select ni into v_ni from recapiti where id_recapito = nvl('||:new.id_recapito || ','|| :old.id_recapito||'); ALLINEA_ANAG_SOGGETTI_TABLE (v_ni); end;';
          ' begin ALLINEA_ANAG_SOGGETTI_TABLE (' ||v_ni||'); end;';
      integritypackage.set_postevent (a_istruzione, a_messaggio);
   EXCEPTION
      WHEN OTHERS
      THEN
         integritypackage.initnestlevel;
         RAISE;
   END;
   end if; -- solo se primo livello
    insert into ALLINEA_ANAG_SOGGETTI_TAB tab
    select v_ni from dual
      where not exists (select 1
                          from ALLINEA_ANAG_SOGGETTI_TAB
                         where ni = v_ni);
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


