CREATE OR REPLACE TRIGGER ANSO_TO_ANAGRAFICI_TIU
/******************************************************************************
       NOME:        ANSO_TO_ANAGRAFICI_TIU
       DESCRIZIONE: Trigger for allineamento fra ANAGRAFE_SOGGETTI e ANAGRAFICI
                    Quando viene fatto aggiornamento dalla vista tutti i record
                    vengono storicizzati.
       ECCEZIONI:   -20007, Identificazione CHIAVE presente in TABLE
       ANNOTAZIONI:
       REVISIONI:
       Rev. Data       Autore Descrizione
       ---- ---------- ------ ------------------------------------------------------
                              Prima Emissione
          1 17/05/2018 SNeg   Se contatto annullato lo chiudo.
          2 30/05/2018 SNeg   Cerco anagrafica aperta
          3 30/05/2018 SNeg   Presso lo considero solo x residenza e non domicilio
          4 27/06/2018 SNeg   Rimanda l'attività al package anagrafici_pkg
          5 05/09/2019 Sneg   Non passo le note anche nel domicilio
          6 05/02/2020 Sneg   Consentire anche solo modifica di competenza e competenza_esclusiva Bug #40420
          7 06/02/2020 SNeg   Integrazione con Personale se il record aperto ha competenza_esclusiva='P'
                              forzare la nuova data ad oggi.Bug #40447
          8 17/05/2021 SNeg   Se nome troppo lungo non posso concatenare i 2 caratteri separatori Bug #50421
      ******************************************************************************/
   INSTEAD OF INSERT OR UPDATE
   ON ANAGRAFE_SOGGETTI    FOR EACH ROW
DECLARE
   integrity_error      EXCEPTION;
   errno                INTEGER;
   errmsg               CHAR (200);
   dummy                INTEGER;
   FOUND                BOOLEAN;
   d_result             AFC_Error.t_error_number;
   d_id_anagrafica      anagrafici.id_anagrafica%TYPE;
   d_id_recapito        recapiti.id_recapito%TYPE;
   d_id_contatto        CONTATTI.id_recapito%TYPE;
   d_contatto_valore    contatti.valore%TYPE;
   d_id_tipo_contatto   tipi_contatto.id_tipo_contatto%TYPE;
   v_new_ni             anagrafici.ni%TYPE;
   v_new_dal            DATE;
   v_id_anagrafica ANAGRAFICI.id_anagrafica%TYPE;
   d_nome anagrafici.nome%TYPE:= :new.nome;
   v_nome anagrafici.nome%TYPE:= :new.nome;
   v_cognome anagrafici.cognome%TYPE:= :new.cognome;
   v_denominazione anagrafici.denominazione%TYPE:= :new.denominazione;
   v_pointer number;
BEGIN
 IF (v_cognome || '  ' || v_nome <>
                                             :OLD.cognome || '  '
                                             || :OLD.nome
            and v_cognome is not null)
            or v_denominazione  is null -- se nulla la valorizzo
         THEN

            IF d_nome IS NOT NULL THEN --rev. 8 inizio
               v_denominazione :=
                            SUBSTR (v_cognome ||'  '||  d_nome
                                  , 1
                                  , 240
                                   );
            else
               v_denominazione :=
                            SUBSTR (v_cognome
                                  , 1
                                  , 240
                                   );
            END IF; --rev. 8 fine

         ELSE
            IF NVL (v_denominazione, ' ') <> NVL (:OLD.denominazione, ' ')
            or  (v_denominazione is not null and v_cognome is  null) -- passata denominazione e non il cognome, nome
            THEN
               v_pointer := INSTR (v_denominazione, '  ');
               IF v_pointer = 0
               THEN
                  v_cognome := RTRIM (v_denominazione);
                  v_nome := NULL;
               ELSE
                  v_cognome :=
                        RTRIM (SUBSTR (v_denominazione
                                     , 1
                                     , v_pointer - 1
                                      ));
                  v_nome :=
                            RTRIM (SUBSTR (v_denominazione, v_pointer + 2));
               END IF;
            END IF;
         END IF;
--
   IF    NVL (:new.dal, trunc(sysdate)) != NVL (:old.dal, trunc(sysdate))
      OR NVL (v_COGNOME, '1') != NVL (:old.COGNOME, '1')
      OR NVL (v_NOME, '1') != NVL (:old.NOME, '1')
      OR NVL (:new.SESSO, '1') != NVL (:old.SESSO, '1')
      OR NVL (:new.DATA_NAS, TO_DATE ('2222222', 'j')) !=
            NVL (:old.DATA_NAS, TO_DATE ('2222222', 'j'))
      OR NVL (:new.PROVINCIA_NAS, 1) != NVL (:old.PROVINCIA_NAS, 1)
      OR NVL (:new.COMUNE_NAS, 1) != NVL (:old.COMUNE_NAS, 1)
      OR NVL (:new.LUOGO_NAS, '1') != NVL (:old.LUOGO_NAS, '1')
      OR NVL (:new.CODICE_FISCALE, '1') != NVL (:old.CODICE_FISCALE, '1')
      OR NVL (:new.CODICE_FISCALE_ESTERO, '1') !=
            NVL (:old.CODICE_FISCALE_ESTERO, '1')
      OR NVL (:new.PARTITA_IVA, '1') != NVL (:old.PARTITA_IVA, '1')
      OR NVL (:new.CITTADINANZA, '1') != NVL (:old.CITTADINANZA, '1')
      OR NVL (:new.GRUPPO_LING, '1') != NVL (:old.GRUPPO_LING, '1')
      OR NVL (:new.INDIRIZZO_RES, '1') != NVL (:old.INDIRIZZO_RES, '1')
      OR NVL (:new.PROVINCIA_RES, '1') != NVL (:old.PROVINCIA_RES, '1')
      OR NVL (:new.COMUNE_RES, '1') != NVL (:old.COMUNE_RES, '1')
      OR NVL (:new.CAP_RES, '1') != NVL (:old.CAP_RES, '1')
      OR NVL (:new.TEL_RES, '1') != NVL (:old.TEL_RES, '1')
      OR NVL (:new.FAX_RES, '1') != NVL (:old.FAX_RES, '1')
      OR NVL (:new.PRESSO, '1') != NVL (:old.PRESSO, '1')
      OR NVL (:new.INDIRIZZO_DOM, '1') != NVL (:old.INDIRIZZO_DOM, '1')
      OR NVL (:new.PROVINCIA_DOM, '1') != NVL (:old.PROVINCIA_DOM, '1')
      OR NVL (:new.COMUNE_DOM, '1') != NVL (:old.COMUNE_DOM, '1')
      OR NVL (:new.CAP_DOM, '1') != NVL (:old.CAP_DOM, '1')
      OR NVL (:new.TEL_DOM, '1') != NVL (:old.TEL_DOM, '1')
      OR NVL (:new.FAX_DOM, '1') != NVL (:old.FAX_DOM, '1')
      --or nvl(:new.UTENTE,'1') != nvl(:old.UTENTE ,'1')
      --or nvl(:new.DATA_AGG,to_date('2222222','j')) != nvl(:old.DATA_AGG ,to_date('2222222','j'))
      -- rev. 6 inizio
      or nvl(:new.COMPETENZA,'1') != nvl(:old.COMPETENZA ,'1')
      or nvl(:new.COMPETENZA_ESCLUSIVA,'1') != nvl(:old.COMPETENZA_ESCLUSIVA ,'1')
      -- rev. 6 fine
      OR NVL (:new.TIPO_SOGGETTO, '1') != NVL (:old.TIPO_SOGGETTO, '1')
      OR NVL (:new.FLAG_TRG, '1') != NVL (:old.FLAG_TRG, '1')
      OR NVL (:new.STATO_CEE, '1') != NVL (:old.STATO_CEE, '1')
      OR NVL (:new.PARTITA_IVA_CEE, '1') != NVL (:old.PARTITA_IVA_CEE, '1')
      OR NVL (:new.FINE_VALIDITA, TO_DATE ('2222222', 'j')) !=
            NVL (:old.FINE_VALIDITA, TO_DATE ('2222222', 'j'))
      OR NVL (:new.AL, TO_DATE ('2222222', 'j')) !=
            NVL (:old.AL, TO_DATE ('2222222', 'j'))
      OR NVL (v_DENOMINAZIONE, '1') != NVL (:old.DENOMINAZIONE, '1')
      OR NVL (:new.INDIRIZZO_WEB, '1') != NVL (:old.INDIRIZZO_WEB, '1')
      OR NVL (:new.NOTE, '1') != NVL (:old.NOTE, '1')
   THEN
--   raise_application_error(-20999,'anagrafica cognome: ' ||v_cognome);
--   raise_application_error(-20999,'anagrafica xxY ' || d_id_anagrafica || ' old_dal:' || :old.dal || ' new_dal:' ||:new.dal);
      IF INSERTING
      THEN
      -- rev. 7 inizio
      v_new_dal := :new.dal; -- uso variabile, in un trigger di instead of
                             -- non si possono cambiare i :new.
        if :new.competenza like 'GP%' and :new.competenza_esclusiva is null
         and get_is_comp_parziale_aperta(:new.ni) = 1
         and :new.dal < trunc(sysdate) then
         -- utilizzando anagrafe lineare
         -- personale sta inserendo record con data precedente alla data di oggi
         -- ma esiste competenza_parziale = 'P'
         -- viene forzato il dal a oggi
            v_new_dal := trunc(sysdate);
         end if;
      -- rev. 7 fine
       v_id_anagrafica :=  anagrafici_pkg.ins_anag_dom_e_res_e_mail (
      p_ni                      => :new.ni,
      p_dal                     => v_new_dal, --:new.dal, -- rev. 7
      p_al                      => :new.al,
      p_cognome                 => v_cognome,
      p_nome                    => v_nome,
      p_sesso                   => :new.sesso,
      p_data_nas                => :new.data_nas,
      p_provincia_nas           => :new.provincia_nas,
      p_comune_nas              => :new.comune_nas,
      p_luogo_nas               => :new.luogo_nas,
      p_codice_fiscale          => :new.codice_fiscale,
      p_codice_fiscale_estero   => :new.codice_fiscale_estero,
      p_partita_iva             => :new.partita_iva,
      p_cittadinanza            => :new.cittadinanza,
      p_gruppo_ling             => :new.gruppo_ling,
      p_competenza              => :new.competenza,
      p_competenza_esclusiva    => :new.competenza_esclusiva,
      p_tipo_soggetto           => :new.tipo_soggetto,
      p_stato_cee               => :new.stato_cee,
      p_partita_iva_cee         => :new.partita_iva_cee,
      p_fine_validita           => :new.fine_validita,
      p_stato_soggetto          => 'U',
      p_denominazione           => v_denominazione,
      p_note_anag               => :new.note,
      ----- dati residenza
      p_descrizione_residenza   => ''
    , p_indirizzo_res           => :new.indirizzo_res
    , p_provincia_res           => :new.provincia_res
    , p_comune_res              => :new.comune_res
    , p_cap_res                 => :new.cap_res
    , p_presso                  => :new.presso
    , p_importanza              => ''
      ---- mail                 => :new.
    , p_mail                    => :new.indirizzo_web
    , p_note_mail               => '' -- rev. 5 :new.note
    , p_importanza_mail         => '',
    ---- tel_res
      p_tel_res                 => :new.tel_res,
      p_note_tel_res            => '', -- rev. 5 :new.note,
      p_importanza_tel_res      => '',
      ---- fax_res
      p_fax_res                 => :new.fax_res,
      p_note_fax_res            => '', -- rev. 5 :new.note,
      p_importanza_fax_res      => ''
      -- dati DOMICILIO
    , p_descrizione_dom         => ''
    , p_indirizzo_dom           => :new.indirizzo_dom
    , p_provincia_dom           => :new.provincia_dom
    , p_comune_dom              => :new.comune_dom
    , p_cap_dom                 => :new.cap_dom
    ---- tel dom                => :new.
    , p_tel_dom                 => :new.tel_dom
--    , p_id_tipo_contatto      => :new.id_tipo_contatto
    , p_note_tel_dom            => '' -- rev. 5 :new.note
    , p_importanza_tel_dom      => ''
    ---- fax dom                => :new.
    , p_fax_dom                 => :new.fax_dom
--    , p_id_tipo_contatto      => :new.id_tipo_contatto
    , p_note_fax_dom            => '', -- rev. 5 :new.note,
      ---- dati generici        => :new.
      p_utente                  => :new.utente,
      p_data_agg                => nvl(:new.data_agg,  SYSDATE),
      p_batch                   =>  0  --= NON batch
                                                   );
      -- insert in contatti
      ELSIF UPDATING
      THEN
        v_id_anagrafica := anagrafici_pkg.upd_anag_dom_e_res_e_mail (
      p_ni                      => :new.ni,
      p_dal                     => :new.dal,
      p_al                      => :new.al,
      p_cognome                 => v_cognome,
      p_nome                    => v_nome,
      p_sesso                   => :new.sesso,
      p_data_nas                => :new.data_nas,
      p_provincia_nas           => :new.provincia_nas,
      p_comune_nas              => :new.comune_nas,
      p_luogo_nas               => :new.luogo_nas,
      p_codice_fiscale          => :new.codice_fiscale,
      p_codice_fiscale_estero   => :new.codice_fiscale_estero,
      p_partita_iva             => :new.partita_iva,
      p_cittadinanza            => :new.cittadinanza,
      p_gruppo_ling             => :new.gruppo_ling,
      p_competenza              => :new.competenza,
      p_competenza_esclusiva    => :new.competenza_esclusiva,
      p_tipo_soggetto           => :new.tipo_soggetto,
      p_stato_cee               => :new.stato_cee,
      p_partita_iva_cee         => :new.partita_iva_cee,
      p_fine_validita           => :new.fine_validita,
      p_stato_soggetto          => 'U',
      p_denominazione           => v_denominazione,
      p_note_anag               => :new.note,
      ----- dati residenza
      p_descrizione_residenza   => ''
    , p_indirizzo_res           => :new.indirizzo_res
    , p_provincia_res           => :new.provincia_res
    , p_comune_res              => :new.comune_res
    , p_cap_res                 => :new.cap_res
    , p_presso                  => :new.presso
    , p_importanza              => ''
      ---- mail                 => :new.
    , p_mail                    => :new.indirizzo_web
    , p_note_mail               => '' -- rev. 5 :new.note
    , p_importanza_mail         => '',
    ---- tel_res
      p_tel_res                 => :new.tel_res,
      p_note_tel_res            => '', -- rev. 5 :new.note,
      p_importanza_tel_res      => '',
      ---- fax_res
      p_fax_res                 => :new.fax_res,
      p_note_fax_res            => '', -- rev. 5 :new.note,
      p_importanza_fax_res      => ''
      -- dati DOMICILIO
    , p_descrizione_dom         => ''
    , p_indirizzo_dom           => :new.indirizzo_dom
    , p_provincia_dom           => :new.provincia_dom
    , p_comune_dom              => :new.comune_dom
    , p_cap_dom                 => :new.cap_dom
    ---- tel dom                => :new.
    , p_tel_dom                 => :new.tel_dom
--    , p_id_tipo_contatto      => :new.id_tipo_contatto
    , p_note_tel_dom            => '' -- rev. 5 :new.note
    , p_importanza_tel_dom      => ''
    ---- fax dom                => :new.
    , p_fax_dom                 => :new.fax_dom
--    , p_id_tipo_contatto      => :new.id_tipo_contatto
    , p_note_fax_dom            => '', -- rev. 5 :new.note,
      ---- dati generici        => :new.
      p_utente                  => :new.utente,
      p_data_agg                => nvl(:new.data_agg, SYSDATE),
      p_batch                   =>  0  --= NON batch
                                                   );
      ELSIF DELETING
      THEN
         raise_application_error (-20999, si4.get_error('A10014')); --'Impossibile cancellare');
      END IF;
   END IF;
EXCEPTION
   WHEN integrity_error
   THEN
      integritypackage.initnestlevel;
      raise_application_error (errno, errmsg, TRUE);
   WHEN OTHERS
   THEN
      integritypackage.initnestlevel;
      RAISE;
END;
/


