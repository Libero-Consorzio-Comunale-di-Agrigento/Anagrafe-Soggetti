CREATE OR REPLACE PROCEDURE ALLINEA_ANAG_SOGGETTI_TABLE (
   p_ni    anagrafici.ni%TYPE)
IS
/******************************************************************************
 NOME:        ALLINEA_ANAG_SOGGETTI_TABLE
 DESCRIZIONE: Allineamento fra dati della tabella orizzontale e tabelle singole
 ARGOMENTI:   Rigenerati in automatico.
 ECCEZIONI:
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
    1 23/05/2018 SNeg   Inserita la distinct
    2 15/10/2019 SNeg   Quando aggiorno lo faccio x ni e dal
    3 02/01/2020 SNeg   x Lentezze prima aggiorno solo elenco ni, dal poi il resto. BUG #39588
    4 12/10/2020 SNeg   Aggiornata mail di un soggetto ma as4_anagrafe_soggetti non allineata BUG #45277
******************************************************************************/
BEGIN
  for v_ni in (select * from ALLINEA_ANAG_SOGGETTI_TAB
                where ni = p_ni) loop
  -- rev.3 inizio
    -- sistema i periodi x ricalcolo anagrafe_soggetti
  DELETE tutti_ni_dal_res_dom_ok
  where (ni, dal) NOT IN (SELECT ni, dal
                              FROM TUTTI_NI_DAL_RES_DOM_OK_VIEW -- rev. 4
                             WHERE ni = v_ni.ni)
   and ni = v_ni.ni;
  INSERT into tutti_ni_dal_res_dom_ok (ni,dal)
  select ni, dal
    FROM TUTTI_NI_DAL_RES_DOM_OK_VIEW c -- rev. 4
      where ni = v_ni.ni
             AND NOT EXISTS
                    (SELECT 1
                       FROM tutti_ni_dal_res_dom_ok t
                      WHERE t.ni = c.ni AND t.dal = c.dal);
    -- cancella i periodi che non esistono più
   DELETE anagrafe_soggetti_table
    WHERE (ni, dal) NOT IN (SELECT ni, dal
                              FROM anagrafe_soggetti_view
                             WHERE ni = v_ni.ni)
      AND ni = v_ni.ni;
  -- rev.3 fine
   FOR v_anag_view
   -- Rev. 1 inizio
      IN (SELECT  distinct v.* -- Rev. 1 fine
            FROM anagrafe_soggetti_view v, anagrafe_soggetti_table t
           WHERE     v.ni = t.ni
                 and v.ni = v_ni.ni
                 AND v.dal = t.dal -- rev.2
                 AND (   NVL (v.id_anagrafica, '1') != NVL (t.id_anagrafica, '1')
                      OR NVL (v.COGNOME, '1') != NVL (t.COGNOME, '1')
                      OR NVL (v.NOME, '1') != NVL (t.NOME, '1')
                      OR NVL (v.SESSO, '1') != NVL (t.SESSO, '1')
                      OR NVL (v.DATA_NAS, TO_DATE ('2222222', 'j')) !=
                            NVL (t.DATA_NAS, TO_DATE ('2222222', 'j'))
                      OR NVL (v.PROVINCIA_NAS, 1) != NVL (t.PROVINCIA_NAS, 1)
                      OR NVL (v.COMUNE_NAS, 1) != NVL (t.COMUNE_NAS, 1)
                      OR NVL (v.LUOGO_NAS, '1') != NVL (t.LUOGO_NAS, '1')
                      OR NVL (v.CODICE_FISCALE, '1') !=
                            NVL (t.CODICE_FISCALE, '1')
                      OR NVL (v.CODICE_FISCALE_ESTERO, '1') !=
                            NVL (t.CODICE_FISCALE_ESTERO, '1')
                      OR NVL (v.PARTITA_IVA, '1') != NVL (t.PARTITA_IVA, '1')
                      OR NVL (v.CITTADINANZA, '1') !=
                            NVL (t.CITTADINANZA, '1')
                      OR NVL (v.GRUPPO_LING, '1') != NVL (t.GRUPPO_LING, '1')
                      OR NVL (v.INDIRIZZO_RES, '1') !=
                            NVL (t.INDIRIZZO_RES, '1')
                      OR NVL (v.PROVINCIA_RES, '1') !=
                            NVL (t.PROVINCIA_RES, '1')
                      OR NVL (v.COMUNE_RES, '1') != NVL (t.COMUNE_RES, '1')
                      OR NVL (v.CAP_RES, '1') != NVL (t.CAP_RES, '1')
                      OR NVL (v.TEL_RES, '1') != NVL (t.TEL_RES, '1')
                      OR NVL (v.FAX_RES, '1') != NVL (t.FAX_RES, '1')
                      OR NVL (v.PRESSO, '1') != NVL (t.PRESSO, '1')
                      OR NVL (v.INDIRIZZO_DOM, '1') !=
                            NVL (t.INDIRIZZO_DOM, '1')
                      OR NVL (v.PROVINCIA_DOM, '1') !=
                            NVL (t.PROVINCIA_DOM, '1')
                      OR NVL (v.COMUNE_DOM, '1') != NVL (t.COMUNE_DOM, '1')
                      OR NVL (v.CAP_DOM, '1') != NVL (t.CAP_DOM, '1')
                      OR NVL (v.TEL_DOM, '1') != NVL (t.TEL_DOM, '1')
                      OR NVL (v.FAX_DOM, '1') != NVL (t.FAX_DOM, '1')
                      or nvl(v.UTENTE,'1') != nvl(t.UTENTE ,'1')
                      or nvl(v.DATA_AGG,to_date('2222222','j')) != nvl(t.DATA_AGG ,to_date('2222222','j'))
                      or nvl(v.COMPETENZA,'1') != nvl(t.COMPETENZA ,'1')
                      or nvl(v.COMPETENZA_ESCLUSIVA,'1') != nvl(t.COMPETENZA_ESCLUSIVA ,'1')
                      OR NVL (v.TIPO_SOGGETTO, '1') !=
                            NVL (t.TIPO_SOGGETTO, '1')
                      OR NVL (v.FLAG_TRG, '1') != NVL (t.FLAG_TRG, '1')
                      OR NVL (v.STATO_CEE, '1') != NVL (t.STATO_CEE, '1')
                      OR NVL (v.PARTITA_IVA_CEE, '1') !=
                            NVL (t.PARTITA_IVA_CEE, '1')
                      OR NVL (v.FINE_VALIDITA, TO_DATE ('2222222', 'j')) !=
                            NVL (t.FINE_VALIDITA, TO_DATE ('2222222', 'j'))
                      OR NVL (v.AL, TO_DATE ('2222222', 'j')) !=
                            NVL (t.AL, TO_DATE ('2222222', 'j'))
                      OR NVL (v.DENOMINAZIONE, '1') !=
                            NVL (t.DENOMINAZIONE, '1')
                      OR NVL (v.INDIRIZZO_WEB, '1') !=
                            NVL (t.INDIRIZZO_WEB, '1')
                      OR NVL (v.NOTE, '1') != NVL (t.NOTE, '1')))
   LOOP
--   raise_application_error(-20999,('inizio ALLINEA ni:'|| v_ni.ni || 'dal:' || to_char(v_anag_view.dal) || ' version:' || v_anag_view.version));
      UPDATE ANAGRAFE_SOGGETTI_TABLE
         SET id_anagrafica = v_anag_view.id_anagrafica,
             NI = v_anag_view.NI,
             DAL = v_anag_view.DAL,
             COGNOME = v_anag_view.COGNOME,
             NOME = v_anag_view.NOME,
             SESSO = v_anag_view.SESSO,
             DATA_NAS = v_anag_view.DATA_NAS,
             PROVINCIA_NAS = v_anag_view.PROVINCIA_NAS,
             COMUNE_NAS = v_anag_view.COMUNE_NAS,
             LUOGO_NAS = v_anag_view.LUOGO_NAS,
             CODICE_FISCALE = v_anag_view.CODICE_FISCALE,
             CODICE_FISCALE_ESTERO = v_anag_view.CODICE_FISCALE_ESTERO,
             PARTITA_IVA = v_anag_view.PARTITA_IVA,
             CITTADINANZA = v_anag_view.CITTADINANZA,
             GRUPPO_LING = v_anag_view.GRUPPO_LING,
             INDIRIZZO_RES = v_anag_view.INDIRIZZO_RES,
             PROVINCIA_RES = v_anag_view.PROVINCIA_RES,
             COMUNE_RES = v_anag_view.COMUNE_RES,
             CAP_RES = v_anag_view.CAP_RES,
             TEL_RES = v_anag_view.TEL_RES, --substr(v_anag_view.TEL_RES,1,14),
             FAX_RES = v_anag_view.fax_res, --substr(v_anag_view.FAX_RES,1,14),
             PRESSO = v_anag_view.PRESSO,
             INDIRIZZO_DOM = v_anag_view.INDIRIZZO_DOM,
             PROVINCIA_DOM = v_anag_view.PROVINCIA_DOM,
             COMUNE_DOM = v_anag_view.COMUNE_DOM,
             CAP_DOM = v_anag_view.CAP_DOM,
             TEL_DOM = v_anag_view.tel_dom , --substr(v_anag_view.TEL_DOM,1,14),
             FAX_DOM = v_anag_view.fax_dom, --substr(v_anag_view.FAX_DOM,1,14),
             UTENTE = v_anag_view.UTENTE,
             DATA_AGG = v_anag_view.DATA_AGG,
             COMPETENZA = v_anag_view.COMPETENZA,
             COMPETENZA_ESCLUSIVA = v_anag_view.COMPETENZA_ESCLUSIVA,
             TIPO_SOGGETTO = v_anag_view.TIPO_SOGGETTO,
             FLAG_TRG = v_anag_view.FLAG_TRG,
             STATO_CEE = v_anag_view.STATO_CEE,
             PARTITA_IVA_CEE = v_anag_view.PARTITA_IVA_CEE,
             FINE_VALIDITA = v_anag_view.FINE_VALIDITA,
             AL = v_anag_view.AL,
             DENOMINAZIONE = v_anag_view.DENOMINAZIONE,
             INDIRIZZO_WEB = v_anag_view.INDIRIZZO_WEB,
             NOTE = v_anag_view.NOTE ,
             VERSION = v_anag_view.VERSION
       WHERE NI = v_anag_view.NI AND DAL = v_anag_view.DAL;
   END LOOP;
--  raise_application_error(-20999,'insert');
   -- inserisce i periodi e dati  nuovi
   INSERT INTO anagrafe_soggetti_table
   (id_anagrafica,
    NI,
             DAL,
             COGNOME,
             NOME,
             SESSO,
             DATA_NAS,
             PROVINCIA_NAS,
             COMUNE_NAS,
             LUOGO_NAS,
             CODICE_FISCALE,
             CODICE_FISCALE_ESTERO,
             PARTITA_IVA,
             CITTADINANZA,
             GRUPPO_LING,
             INDIRIZZO_RES,
             PROVINCIA_RES,
             COMUNE_RES,
             CAP_RES,
             TEL_RES,
             FAX_RES,
             PRESSO,
             INDIRIZZO_DOM,
             PROVINCIA_DOM,
             COMUNE_DOM,
             CAP_DOM,
             TEL_DOM,
             FAX_DOM,
             UTENTE,
             DATA_AGG,
             COMPETENZA,
             COMPETENZA_ESCLUSIVA,
             TIPO_SOGGETTO,
             FLAG_TRG,
             STATO_CEE,
             PARTITA_IVA_CEE,
             FINE_VALIDITA,
             AL,
             DENOMINAZIONE,
             INDIRIZZO_WEB,
             NOTE,
             VERSION)
      SELECT id_anagrafica,
             NI,
             DAL,
             COGNOME,
             NOME,
             SESSO,
             DATA_NAS,
             PROVINCIA_NAS,
             COMUNE_NAS,
             LUOGO_NAS,
             CODICE_FISCALE,
             CODICE_FISCALE_ESTERO,
             PARTITA_IVA,
             CITTADINANZA,
             GRUPPO_LING,
             INDIRIZZO_RES,
             PROVINCIA_RES,
             COMUNE_RES,
             CAP_RES,
             tel_res, --substr(TEL_RES,1,14),
             fax_res, --substr(FAX_RES,1,14),
             PRESSO,
             INDIRIZZO_DOM,
             PROVINCIA_DOM,
             COMUNE_DOM,
             CAP_DOM,
             tel_dom, --substr(TEL_DOM,1,14),
             fax_dom, --substr(FAX_DOM,1,14),
             UTENTE,
             DATA_AGG,
             COMPETENZA,
             COMPETENZA_ESCLUSIVA,
             TIPO_SOGGETTO,
             FLAG_TRG,
             STATO_CEE,
             PARTITA_IVA_CEE,
             FINE_VALIDITA,
             AL,
             DENOMINAZIONE,
             INDIRIZZO_WEB,
             NOTE,
             VERSION
        FROM anagrafe_soggetti_view v
       WHERE     ni = v_ni.ni
             AND NOT EXISTS
                    (SELECT 1
                       FROM anagrafe_soggetti_table t
                      WHERE t.ni = v.ni AND t.dal = v.dal);
  end loop;
-- aggiorna i record se diversi
-- cancella il record trattato
delete ALLINEA_ANAG_SOGGETTI_TAB
where ni = p_ni;
END;
/

