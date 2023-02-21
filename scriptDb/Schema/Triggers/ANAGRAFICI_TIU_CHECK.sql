CREATE OR REPLACE TRIGGER ANAGRAFICI_TIU_CHECK
/******************************************************************************
 NOME:        ANAGRAFICI_TIU_check
 DESCRIZIONE: Trigger for Set DATA Integrity
                          Set FUNCTIONAL Integrity
                       on Table ANAGRAFICI
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 1    12/06/2017  SNeg  Controlli indicati da Venezia sulle anagrafiche
 2    09/01/2018  SNeg  Aggiunti parametri a anagrafici_check x consentire
                        chiusura di soggetti che sono attivi insieme ma
                        che sono stati gestiti a trigger disabilitati.
 3    07/03/2018  SNeg  Verificare in alternativa codice_fiscale/codice_fiscale estero
                        e partita_iva/partita_iva_cee 
 4    02/07/2018  SNeg  Verifica se il cliente è Venezia dal registro.
 5    20/09/2018  SNeg  Aggiunto parametro stato diventa chiuso.
******************************************************************************/
   AFTER INSERT OR UPDATE ON ANAGRAFICI FOR EACH ROW
DECLARE
   integrity_error  EXCEPTION;
   errno            INTEGER;
   errmsg           CHAR(200);
   FOUND            BOOLEAN;
   v_tipo_operazione varchar2(1);
   v_modificati_attributi number := 0;
   v_valorizzato_al number := 0;
   v_get_pref_alternativa impostazioni.t_impostazioni;
   v_stato_diventa_chiuso number := 0;
BEGIN
   v_get_pref_alternativa := impostazioni.get_preferenza ('Storicizzare', '') ;
   if v_get_pref_alternativa = 'VENEZIA' then 
   begin
   if updating then
     v_tipo_operazione := 'U';
   elsif inserting then
     v_tipo_operazione := 'I';
   else
     raise_application_error (-20999,si4.get_error('A10014')); --'Non è possibile cancellare');
   end if;

   IF  NVL (:NEW.cognome, 'xxx') <> NVL (:OLD.cognome, 'xxx')
          OR NVL (:NEW.nome, 'xxx') <> NVL (:OLD.nome, 'xxx')
          OR NVL (:NEW.codice_fiscale, 'xxx') <> NVL (:OLD.codice_fiscale, 'xxx')
          -- Rev. 3 inizio modifica
          OR NVL (:NEW.codice_fiscale_estero, 'xxx') <> NVL (:OLD.codice_fiscale_estero, 'xxx')
          OR NVL (:NEW.partita_iva_cee, 'xxx') <> NVL (:OLD.partita_iva_cee, 'xxx')
          -- Rev. 3 fine modifica
          OR NVL (:NEW.partita_iva, 'xxx') <> NVL (:OLD.partita_iva, 'xxx')
          or (:old.dal != :new.dal)
   THEN
      v_modificati_attributi := 1; -- ci sono state modifiche
   END IF;
--   raise_application_error (-20999,'valori al ' || :old.al ||'->'|| :new.al);
   IF  :old.al is null and :new.al is not null then 
      v_valorizzato_al := 1; -- modificato valore AL
   END IF;
   
      IF  nvl(:old.stato_soggetto,'U') != 'C' and nvl(:new.stato_soggetto,'U') = 'C' then 
      v_stato_diventa_chiuso := 1; -- modificato stato a Chiuso
   END IF;
   
   if :new.stato_soggetto = 'C' and :new.al is null then
       raise_application_error (-20999, 
                               si4.get_error('A10093')
                               --'Tipo soggetto non previsto'
                               );
   end if;
    
        DECLARE
            a_istruzione   VARCHAR2 (2000);
            a_messaggio    VARCHAR2 (2000);
            v_valore varchar2(2000):= 'new= ' || :NEW.TIPO_SOGGETTO || 'old= ' || :OLD.TIPO_SOGGETTO;
         BEGIN
            a_messaggio := '';
            a_istruzione :=
                  'begin anagrafici_check ('
               || :NEW.ni
               || ', to_date('''
               || TO_CHAR (:NEW.dal, 'dd/mm/yyyy hh24:mi:ss')
               || ''',''dd/mm/yyyy hh24:mi:ss''), '
               || ' to_date('''
               || TO_CHAR (:NEW.al, 'dd/mm/yyyy hh24:mi:ss')
               || ''',''dd/mm/yyyy hh24:mi:ss''), '''
               || REPLACE (:NEW.cognome
                         , ''''
                         , ''''''
                          )
               || ''', '''
               || REPLACE (:NEW.nome
                         , ''''
                         , ''''''
                          )
               || ''', '''
               || REPLACE (:NEW.PARTITA_IVA
                         , ''''
                         , ''''''
                          )
               || ''', '''               
               || REPLACE (:NEW.PARTITA_IVA_cee
                         , ''''
                         , ''''''
                          )
               || ''', ''' 
               || REPLACE (:NEW.CODICE_FISCALE
                         , ''''
                         , ''''''
                          )
               || ''', '''
               || REPLACE (:NEW.CODICE_FISCALE_ESTERO
                         , ''''
                         , ''''''
                          )
               || ''', '''
               || :NEW.TIPO_SOGGETTO
               || ''', '''
               || v_tipo_operazione
               || ''', '''
               || :NEW.COMPETENZA
               || ''', '''
               || :NEW.COMPETENZA_ESCLUSIVA
               ||''''
               ||',' 
               || v_modificati_attributi
               ||',' 
               || v_valorizzato_al
               ||',' 
               || v_stato_diventa_chiuso
               ||' ); end;';
               
                            
            integritypackage.set_postevent (a_istruzione, a_messaggio);
         EXCEPTION
            WHEN OTHERS
            THEN
               integritypackage.initnestlevel;
               RAISE;
         END;
         
         
         
-- check_anagrafica (
--   p_ni      => :new.ni,
--   p_dal    => :new.dal,
--   p_cognome => :new.cognome,
--   p_nome    => :new.nome,
--   p_partita_iva => :new.partita_iva,
--   p_codice_fiscale => :new.codice_fiscale,
--   p_tipo_soggetto => :new.tipo_soggetto,
--   p_tipo_operazione => v_tipo_operazione ); 
EXCEPTION
   WHEN integrity_error THEN
        Integritypackage.InitNestLevel;
        RAISE_APPLICATION_ERROR(errno, errmsg);
   WHEN OTHERS THEN
        Integritypackage.InitNestLevel;
        RAISE;
end;
end if;
   
END;
/


