CREATE OR REPLACE PROCEDURE ALLINEA_ANAG_SOGGETTI_TABLE_TR (
   p_ni    anagrafici.ni%TYPE)
IS
-- usare x trasco
BEGIN
 
    -- cancella i periodi che non esistono più
   DELETE anagrafe_soggetti_table
    WHERE (ni, dal) NOT IN (SELECT ni, dal
                              FROM anagrafe_soggetti_view
                             WHERE ni = p_ni)
      AND ni = p_ni;


   FOR v_anag_view
      IN (SELECT v.*
            FROM anagrafe_soggetti_view v
           WHERE v.ni = p_ni)
   LOOP
   
--   raise_application_error(-20999,('inizio ALLINEA ni:'|| p_ni || 'dal:' || to_char(v_anag_view.dal) || ' version:' || v_anag_view.version));
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
       WHERE     ni = p_ni
             AND NOT EXISTS
                    (SELECT 1
                       FROM anagrafe_soggetti_table t
                      WHERE t.ni = v.ni AND t.dal = v.dal);
-- aggiorna i record se diversi
END;
/

