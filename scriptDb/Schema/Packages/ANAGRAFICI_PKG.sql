CREATE OR REPLACE PACKAGE anagrafici_pkg
IS
/******************************************************************************
 NOME:        anagrafici_pkg
 DESCRIZIONE: Gestione tabella ANAGRAFICI.
 ANNOTAZIONI: .
  #################################################
    ATTENZIONE: se cambia questo package ricompilarlo
    anche come anagrafici_pkg_trasco
    sostituendo tutte le occorrenze di:
    TUTTI_NI_DAL_RES_DOM_OK
    con
    TUTTI_NI_DAL_RES_DOM_OK_TRASCO
  #################################################
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000                       Prima emissione
 001   25/09/2018  SNeg    Introdotta get_tipo_struttura
 002   19/02/2019  SNeg    Introdotta v_aggiornamento_da_package
 003   20/11/2020  SNeg    Impedire aggiornamento di dati storici Introdotta function is_ultimo_dal Bug #34914
 004   04/04/2022  MMon    #54239 Modifiche per scarico IPA
******************************************************************************/
   non_trovato_comune exception;
   pragma exception_init( non_trovato_comune, -20942 );
   s_non_trovato_comune_num constant AFC_Error.t_error_number := -20942;
   s_non_trovato_comune_msg constant AFC_Error.t_error_msg := 'A10021';
   non_trovato_tipo_sogg exception;
   pragma exception_init( non_trovato_tipo_sogg, -20943 );
   s_non_trovato_tipo_sogg_num constant AFC_Error.t_error_number := -20943;
   s_non_trovato_tipo_sogg_msg constant AFC_Error.t_error_msg := 'A10054';
   trovato_blocco_record exception;
   pragma exception_init( trovato_blocco_record, -20905 );
   s_trovato_blocco_record_num constant AFC_Error.t_error_number := -20905;
   s_trovato_blocco_record_msg constant AFC_Error.t_error_msg := 'A10044';
   trovato_recapito exception;
   pragma exception_init( trovato_recapito, -20906 );
   s_trovato_recapito_num constant AFC_Error.t_error_number := -20906;
   s_trovato_recapito_msg constant AFC_Error.t_error_msg := 'A10048';
   non_modificabile_storico exception;
   pragma exception_init( non_modificabile_storico, -20907 );
   s_non_modificabile_storico_num constant AFC_Error.t_error_number := -20907;
   s_non_modificabile_storico_msg constant AFC_Error.t_error_msg := 'A10046';
   trasco number := 0;
   -- necessario x controllo su recapiti da non considerare in trasco
   -- se aggiornamento tramite package non uso il trigger x fare l'allineamento
   -- ma lo fa da package.
    v_aggiornamento_da_package_on number := 0;
   -- da modificare solo x il primo caricamento
   PROCEDURE init_ni (p_ni IN OUT anagrafici.ni%TYPE);
   FUNCTION error_message (p_err_number IN AFC_Error.t_error_number)
      RETURN AFC_Error.t_error_msg;
   PROCEDURE raise_error_message (
      p_error_number   IN AFC_Error.t_error_number,
      p_precisazione   IN VARCHAR2 DEFAULT NULL);
   FUNCTION get_recapito_info (p_ni           anagrafici.ni%TYPE,
                               p_dal          anagrafici.dal%TYPE,
                               p_campo        VARCHAR2,
                               p_tipo_info    VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION get_contatto_info (p_ni           anagrafici.ni%TYPE,
                               p_dal          anagrafici.dal%TYPE,
                               p_campo        VARCHAR2,
                               p_tipo_info    VARCHAR2)
      RETURN VARCHAR2;
      FUNCTION get_ultimo_recapito_info (p_ni           anagrafici.ni%TYPE,
                               p_dal          anagrafici.dal%TYPE,
                               p_campo        VARCHAR2,
                               p_tipo_info    VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION get_ultimo_contatto_info (p_ni           anagrafici.ni%TYPE,
                               p_dal          anagrafici.dal%TYPE,
                               p_campo        VARCHAR2,
                               p_tipo_info    VARCHAR2)
      RETURN VARCHAR2;
      FUNCTION get_recapito_ad_oggi_info (p_ni           anagrafici.ni%TYPE,
                               p_dal          anagrafici.dal%TYPE,
                               p_campo        VARCHAR2,
                               p_tipo_info    VARCHAR2)
      RETURN VARCHAR2;
      FUNCTION get_contatto_ad_oggi_info (p_ni           anagrafici.ni%TYPE,
                               p_dal          anagrafici.dal%TYPE,
                               p_campo        VARCHAR2,
                               p_tipo_info    VARCHAR2)
      RETURN VARCHAR2;
  procedure upd
 (p_NEW_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
, p_NEW_ni  in ANAGRAFICI.ni%type default afc.default_null('ANAGRAFICI.ni')
, p_NEW_dal  in ANAGRAFICI.dal%type default afc.default_null('ANAGRAFICI.dal')
, p_NEW_al  in ANAGRAFICI.al%type default afc.default_null('ANAGRAFICI.al')
, p_NEW_cognome  in ANAGRAFICI.cognome%type default afc.default_null('ANAGRAFICI.cognome')
, p_NEW_nome  in ANAGRAFICI.nome%type default afc.default_null('ANAGRAFICI.nome')
, p_NEW_sesso  in ANAGRAFICI.sesso%type default afc.default_null('ANAGRAFICI.sesso')
, p_NEW_data_nas  in ANAGRAFICI.data_nas%type default afc.default_null('ANAGRAFICI.data_nas')
, p_NEW_provincia_nas  in ANAGRAFICI.provincia_nas%type default afc.default_null('ANAGRAFICI.provincia_nas')
, p_NEW_comune_nas  in ANAGRAFICI.comune_nas%type default afc.default_null('ANAGRAFICI.comune_nas')
, p_NEW_luogo_nas  in ANAGRAFICI.luogo_nas%type default afc.default_null('ANAGRAFICI.luogo_nas')
, p_NEW_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default afc.default_null('ANAGRAFICI.codice_fiscale')
, p_NEW_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default afc.default_null('ANAGRAFICI.codice_fiscale_estero')
, p_NEW_partita_iva  in ANAGRAFICI.partita_iva%type default afc.default_null('ANAGRAFICI.partita_iva')
, p_NEW_cittadinanza  in ANAGRAFICI.cittadinanza%type default afc.default_null('ANAGRAFICI.cittadinanza')
, p_NEW_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default afc.default_null('ANAGRAFICI.gruppo_ling')
, p_NEW_competenza  in ANAGRAFICI.competenza%type default afc.default_null('ANAGRAFICI.competenza')
, p_NEW_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default afc.default_null('ANAGRAFICI.competenza_esclusiva')
, p_NEW_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default afc.default_null('ANAGRAFICI.tipo_soggetto')
, p_NEW_stato_cee  in ANAGRAFICI.stato_cee%type default afc.default_null('ANAGRAFICI.stato_cee')
, p_NEW_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default afc.default_null('ANAGRAFICI.partita_iva_cee')
, p_NEW_fine_validita  in ANAGRAFICI.fine_validita%type default afc.default_null('ANAGRAFICI.fine_validita')
, p_NEW_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default afc.default_null('ANAGRAFICI.stato_soggetto')
, p_NEW_denominazione  in ANAGRAFICI.denominazione%type default afc.default_null('ANAGRAFICI.denominazione')
, p_NEW_note  in ANAGRAFICI.note%type default afc.default_null('ANAGRAFICI.note')
, p_NEW_version  in ANAGRAFICI.version%type default afc.default_null('ANAGRAFICI.version')
, p_NEW_utente  in ANAGRAFICI.utente%type default afc.default_null('ANAGRAFICI.utente')
, p_NEW_data_aggiornamento  in ANAGRAFICI.data_agg%type default afc.default_null('ANAGRAFICI.data_agg')
, p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
) ;
--
---- Aggiornamento di una riga
--   procedure upd  /*+ SOA  */
--   (
--     p_check_OLD  in integer default 0
--   , p_NEW_id_anagrafica  in ANAGRAFICI.id_anagrafica%type
--   , p_OLD_id_anagrafica  in ANAGRAFICI.id_anagrafica%type default null
--   , p_NEW_ni  in ANAGRAFICI.ni%type default afc.default_null('ANAGRAFICI.ni')
--   , p_OLD_ni  in ANAGRAFICI.ni%type default null
--   , p_NEW_dal  in ANAGRAFICI.dal%type default afc.default_null('ANAGRAFICI.dal')
--   , p_OLD_dal  in ANAGRAFICI.dal%type default null
--   , p_NEW_al  in ANAGRAFICI.al%type default afc.default_null('ANAGRAFICI.al')
--   , p_OLD_al  in ANAGRAFICI.al%type default null
--   , p_NEW_cognome  in ANAGRAFICI.cognome%type default afc.default_null('ANAGRAFICI.cognome')
--   , p_OLD_cognome  in ANAGRAFICI.cognome%type default null
--   , p_NEW_nome  in ANAGRAFICI.nome%type default afc.default_null('ANAGRAFICI.nome')
--   , p_OLD_nome  in ANAGRAFICI.nome%type default null
--   , p_NEW_sesso  in ANAGRAFICI.sesso%type default afc.default_null('ANAGRAFICI.sesso')
--   , p_OLD_sesso  in ANAGRAFICI.sesso%type default null
--   , p_NEW_data_nas  in ANAGRAFICI.data_nas%type default afc.default_null('ANAGRAFICI.data_nas')
--   , p_OLD_data_nas  in ANAGRAFICI.data_nas%type default null
--   , p_NEW_provincia_nas  in ANAGRAFICI.provincia_nas%type default afc.default_null('ANAGRAFICI.provincia_nas')
--   , p_OLD_provincia_nas  in ANAGRAFICI.provincia_nas%type default null
--   , p_NEW_comune_nas  in ANAGRAFICI.comune_nas%type default afc.default_null('ANAGRAFICI.comune_nas')
--   , p_OLD_comune_nas  in ANAGRAFICI.comune_nas%type default null
--   , p_NEW_luogo_nas  in ANAGRAFICI.luogo_nas%type default afc.default_null('ANAGRAFICI.luogo_nas')
--   , p_OLD_luogo_nas  in ANAGRAFICI.luogo_nas%type default null
--   , p_NEW_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default afc.default_null('ANAGRAFICI.codice_fiscale')
--   , p_OLD_codice_fiscale  in ANAGRAFICI.codice_fiscale%type default null
--   , p_NEW_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default afc.default_null('ANAGRAFICI.codice_fiscale_estero')
--   , p_OLD_codice_fiscale_estero  in ANAGRAFICI.codice_fiscale_estero%type default null
--   , p_NEW_partita_iva  in ANAGRAFICI.partita_iva%type default afc.default_null('ANAGRAFICI.partita_iva')
--   , p_OLD_partita_iva  in ANAGRAFICI.partita_iva%type default null
--   , p_NEW_cittadinanza  in ANAGRAFICI.cittadinanza%type default afc.default_null('ANAGRAFICI.cittadinanza')
--   , p_OLD_cittadinanza  in ANAGRAFICI.cittadinanza%type default null
--   , p_NEW_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default afc.default_null('ANAGRAFICI.gruppo_ling')
--   , p_OLD_gruppo_ling  in ANAGRAFICI.gruppo_ling%type default null
--   , p_NEW_competenza  in ANAGRAFICI.competenza%type default afc.default_null('ANAGRAFICI.competenza')
--   , p_OLD_competenza  in ANAGRAFICI.competenza%type default null
--   , p_NEW_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default afc.default_null('ANAGRAFICI.competenza_esclusiva')
--   , p_OLD_competenza_esclusiva  in ANAGRAFICI.competenza_esclusiva%type default null
--   , p_NEW_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default afc.default_null('ANAGRAFICI.tipo_soggetto')
--   , p_OLD_tipo_soggetto  in ANAGRAFICI.tipo_soggetto%type default null
--   , p_NEW_stato_cee  in ANAGRAFICI.stato_cee%type default afc.default_null('ANAGRAFICI.stato_cee')
--   , p_OLD_stato_cee  in ANAGRAFICI.stato_cee%type default null
--   , p_NEW_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default afc.default_null('ANAGRAFICI.partita_iva_cee')
--   , p_OLD_partita_iva_cee  in ANAGRAFICI.partita_iva_cee%type default null
--   , p_NEW_fine_validita  in ANAGRAFICI.fine_validita%type default afc.default_null('ANAGRAFICI.fine_validita')
--   , p_OLD_fine_validita  in ANAGRAFICI.fine_validita%type default null
--   , p_NEW_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default afc.default_null('ANAGRAFICI.stato_soggetto')
--   , p_OLD_stato_soggetto  in ANAGRAFICI.stato_soggetto%type default null
--   , p_NEW_denominazione  in ANAGRAFICI.denominazione%type default afc.default_null('ANAGRAFICI.denominazione')
--   , p_OLD_denominazione  in ANAGRAFICI.denominazione%type default null
--   , p_NEW_note  in ANAGRAFICI.note%type default afc.default_null('ANAGRAFICI.note')
--   , p_OLD_note  in ANAGRAFICI.note%type default null
--   , p_NEW_version  in ANAGRAFICI.version%type default afc.default_null('ANAGRAFICI.version')
--   , p_OLD_version  in ANAGRAFICI.version%type default null
--   , p_NEW_utente  in ANAGRAFICI.utente%type default afc.default_null('ANAGRAFICI.utente')
--   , p_OLD_utente  in ANAGRAFICI.utente%type default null
--   , p_NEW_data_agg  in ANAGRAFICI.data_agg%type default afc.default_null('ANAGRAFICI.data_agg')
--   , p_OLD_data_agg  in ANAGRAFICI.data_agg%type default null
--   , p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
--   );
   FUNCTION ins (
      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
      p_dal                     IN ANAGRAFICI.dal%TYPE,
      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN ANAGRAFICI.provincia_nas%TYPE DEFAULT NULL,
      p_comune_nas              IN ANAGRAFICI.comune_nas%TYPE DEFAULT NULL,
      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
      p_note                    IN ANAGRAFICI.note%TYPE DEFAULT NULL,
      p_version                 IN ANAGRAFICI.version%TYPE DEFAULT NULL,
      p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
      p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE,
      p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
                                                   )
      RETURN NUMBER;
--FUNCTION ins_anag_e_res_e_mail (
--      -- dati anagrafica
--      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
--      p_dal                     IN ANAGRAFICI.dal%TYPE,
--      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
--      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
--      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
--      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
--      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
--      p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
--      p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
--      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
--      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
--      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
--      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
--      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
--      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
--      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
--      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
--      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
--      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
--      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
--      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
--      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
-- --     p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
--      p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
--      ----- dati residenza
--      p_descrizione_residenza  in RECAPITI.descrizione%type default null
--    , p_indirizzo_res  in RECAPITI.indirizzo%type default null
--    , p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
--    , p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
--    , p_cap_res  in RECAPITI.cap%type default null
--    , p_presso  in RECAPITI.presso%type default null
--    , p_importanza  in RECAPITI.importanza%type default null
--      ---- mail
--    , p_mail  in CONTATTI.valore%type default null
--    , p_note_mail  in CONTATTI.note%type default null
--    , p_importanza_mail  in CONTATTI.importanza%type default null,
--    ---- tel_res
--      p_tel_res                 in CONTATTI.valore%type DEFAULT NULL,
--      p_note_tel_res  in CONTATTI.note%type default null,
--      p_importanza_tel_res  in CONTATTI.importanza%type default null,
--      ---- fax_res
--      p_fax_res  in CONTATTI.valore%type default null,
--      p_note_fax_res  in CONTATTI.note%type default null,
--      p_importanza_fax_res  in CONTATTI.importanza%type default null,
--      ---- dati generici
--      p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
--      p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
--      --,
----      p_batch                      NUMBER DEFAULT 1           -- 0 = NON batch
--                                                   )
--      RETURN NUMBER;
--
--    FUNCTION upd_anag_e_res_e_mail (
--      -- dati anagrafica
--      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
--      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
--      p_dal                     IN ANAGRAFICI.dal%TYPE,
--      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
--      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
--      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
--      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
--      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
--      p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
--      p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
--      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
--      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
--      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
--      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
--      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
--      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
--      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
--      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
--      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
--      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
--      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
--      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
--      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
----      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
--      p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
--      ----- dati residenza
--      p_descrizione_residenza  in RECAPITI.descrizione%type default null
--    , p_indirizzo_res  in RECAPITI.indirizzo%type default null
--    , p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
--    , p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
--    , p_cap_res  in RECAPITI.cap%type default null
--    , p_presso  in RECAPITI.presso%type default null
--    , p_importanza  in RECAPITI.importanza%type default null
--      ---- mail
--    , p_mail  in CONTATTI.valore%type default null
--    , p_note_mail  in CONTATTI.note%type default null
--    , p_importanza_mail  in CONTATTI.importanza%type default null,
--    ---- tel_res
--      p_tel_res                 in CONTATTI.valore%type DEFAULT NULL,
--      p_note_tel_res  in CONTATTI.note%type default null,
--      p_importanza_tel_res  in CONTATTI.importanza%type default null,
--      ---- fax_res
--      p_fax_res  in CONTATTI.valore%type default null,
--      p_note_fax_res  in CONTATTI.note%type default null,
--      p_importanza_fax_res  in CONTATTI.importanza%type default null,
--      ---- dati generici
--      p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
--      p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
----      ,
----      p_batch                      NUMBER DEFAULT 1           -- 0 = NON batch
--                                                   )
--      RETURN NUMBER;
      FUNCTION ins_anag_dom_e_res_e_mail_desc (
      -- dati anagrafica
--      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
      p_dal                     IN ANAGRAFICI.dal%TYPE,
      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
      p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
      p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
      ----- dati residenza
--      p_id_recapito  in RECAPITI.id_recapito%type default null
--    , p_ni  in RECAPITI.ni%type
--    , p_dal  in RECAPITI.dal%type
--    , p_al  in RECAPITI.al%type default null
      p_descrizione_residenza  in RECAPITI.descrizione%type default null --p_descrizione
--    , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type
    , p_indirizzo_res  in RECAPITI.indirizzo%type default null
    , p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
    , p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
    , p_cap_res  in RECAPITI.cap%type default null
    , p_presso  in RECAPITI.presso%type default null
    , p_importanza  in RECAPITI.importanza%type default null
      ---- mail
    , p_mail  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_mail  in CONTATTI.note%type default null
    , p_importanza_mail  in CONTATTI.importanza%type default null
    ---- tel res
    , p_tel_res  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_tel_res  in CONTATTI.note%type default null
    , p_importanza_tel_res  in CONTATTI.importanza%type default null
    ---- fax res
    , p_fax_res  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_fax_res  in CONTATTI.note%type default null
    , p_importanza_fax_res  in CONTATTI.importanza%type default null
      -- dati DOMICILIO
    , p_descrizione_dom  in RECAPITI.descrizione%type default null --p_descrizione
    , p_indirizzo_dom  in RECAPITI.indirizzo%type default null
    , p_provincia_dom           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL
    , p_comune_dom              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL
    , p_cap_dom  in RECAPITI.cap%type default null
    ---- tel dom
    , p_tel_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_tel_dom  in CONTATTI.note%type default null
    , p_importanza_tel_dom  in CONTATTI.importanza%type default null
    ---- fax dom
    , p_fax_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_fax_dom  in CONTATTI.note%type default null
      ---- dati generici
    ,  p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL
     , p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
      ,
      p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
                                                   )
      RETURN NUMBER;
           FUNCTION ins_anag_dom_e_res_e_mail (
      -- dati anagrafica
--      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
      p_dal                     IN ANAGRAFICI.dal%TYPE,
      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
      p_comune_nas              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
      p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
      ----- dati residenza
--      p_id_recapito  in RECAPITI.id_recapito%type default null
--    , p_ni  in RECAPITI.ni%type
--    , p_dal  in RECAPITI.dal%type
--    , p_al  in RECAPITI.al%type default null
      p_descrizione_residenza  in RECAPITI.descrizione%type default null --p_descrizione
--    , p_id_tipo_recapito  in RECAPITI.id_tipo_recapito%type
    , p_indirizzo_res  in RECAPITI.indirizzo%type default null
    , p_provincia_res           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL
    , p_comune_res              IN AD4_COMUNI.comune%TYPE DEFAULT NULL
    , p_cap_res  in RECAPITI.cap%type default null
    , p_presso  in RECAPITI.presso%type default null
    , p_importanza  in RECAPITI.importanza%type default null
      ---- mail
    , p_mail  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_mail  in CONTATTI.note%type default null
    , p_importanza_mail  in CONTATTI.importanza%type default null
    ---- tel res
    , p_tel_res  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_tel_res  in CONTATTI.note%type default null
    , p_importanza_tel_res  in CONTATTI.importanza%type default null
    ---- fax res
    , p_fax_res  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_fax_res  in CONTATTI.note%type default null
    , p_importanza_fax_res  in CONTATTI.importanza%type default null
      -- dati DOMICILIO
    , p_descrizione_dom  in RECAPITI.descrizione%type default null --p_descrizione
    , p_indirizzo_dom  in RECAPITI.indirizzo%type default null
    , p_provincia_dom           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL
    , p_comune_dom              IN AD4_COMUNI.comune%TYPE DEFAULT NULL
    , p_cap_dom  in RECAPITI.cap%type default null
    ---- tel dom
    , p_tel_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_tel_dom  in CONTATTI.note%type default null
    , p_importanza_tel_dom  in CONTATTI.importanza%type default null
    ---- fax dom
    , p_fax_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_fax_dom  in CONTATTI.note%type default null
      ---- dati generici
    ,  p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL
     , p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
      ,
      p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
                                                   )
      RETURN NUMBER;
       FUNCTION upd_anag_dom_e_res_e_mail (
      -- dati anagrafica
      --p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
      p_ni                      IN ANAGRAFICI.ni%TYPE,
      p_dal                     IN ANAGRAFICI.dal%TYPE,
      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL,
      p_comune_nas              IN AD4_COMUNI.comune%TYPE DEFAULT NULL,
      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
      p_denominazione           IN ANAGRAFICI.denominazione%TYPE DEFAULT NULL,
      p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
      ----- dati residenza
      p_descrizione_residenza  in RECAPITI.descrizione%type default null
    , p_indirizzo_res  in RECAPITI.indirizzo%type default null
    , p_provincia_res           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL
    , p_comune_res              IN AD4_COMUNI.comune%TYPE DEFAULT NULL
    , p_cap_res  in RECAPITI.cap%type default null
    , p_presso  in RECAPITI.presso%type default null
    , p_importanza  in RECAPITI.importanza%type default null
      ---- mail
    , p_mail  in CONTATTI.valore%type default null
    , p_note_mail  in CONTATTI.note%type default null
    , p_importanza_mail  in CONTATTI.importanza%type default null,
    ---- tel_res
      p_tel_res                 in CONTATTI.valore%type DEFAULT NULL,
      p_note_tel_res  in CONTATTI.note%type default null,
      p_importanza_tel_res  in CONTATTI.importanza%type default null,
      ---- fax_res
      p_fax_res  in CONTATTI.valore%type default null,
      p_note_fax_res  in CONTATTI.note%type default null,
      p_importanza_fax_res  in CONTATTI.importanza%type default null
      -- dati DOMICILIO
    , p_descrizione_dom  in RECAPITI.descrizione%type default null --p_descrizione
    , p_indirizzo_dom  in RECAPITI.indirizzo%type default null
    , p_provincia_dom           IN AD4_PROVINCE.provincia%TYPE DEFAULT NULL
    , p_comune_dom              IN AD4_COMUNI.comune%TYPE DEFAULT NULL
    , p_cap_dom  in RECAPITI.cap%type default null
    ---- tel dom
    , p_tel_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_tel_dom  in CONTATTI.note%type default null
    , p_importanza_tel_dom  in CONTATTI.importanza%type default null
    ---- fax dom
    , p_fax_dom  in CONTATTI.valore%type  default null-- p_valore
--    , p_id_tipo_contatto  in CONTATTI.id_tipo_contatto%type -- FISSO
    , p_note_fax_dom  in CONTATTI.note%type default null,
      ---- dati generici
      p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
      p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE
      ,
      p_batch                      NUMBER DEFAULT 0           -- 0 = NON batch
                                                   )
      RETURN NUMBER;
      PROCEDURE chiusura_anagrafica (p_ni    IN ANAGRAFICI.ni%TYPE,
                           p_al      anagrafici.al%TYPE);
      FUNCTION get_ultimo_al (p_ni    IN ANAGRAFICI.ni%TYPE,
                           p_dal      anagrafici.dal%TYPE,
                           p_anag_al  anagrafici.al%TYPE)
      RETURN ANAGRAFICI.al%TYPE;
    FUNCTION get_dal_attuale_ni (p_ni IN ANAGRAFICI.ni%TYPE)
      RETURN ANAGRAFICI.dal%TYPE;
    FUNCTION get_al_attuale_ni (p_ni IN ANAGRAFICI.ni%TYPE)
      RETURN ANAGRAFICI.al%TYPE;
   FUNCTION is_competenza_ok (
      p_competenza                 IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
      p_competenza_old             IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
      RETURN AFC_Error.t_error_number;
   FUNCTION is_modificabile_ok (
      p_ni                         IN anagrafici.ni%TYPE,
      p_dal                        IN anagrafici.dal%TYPE,
      p_competenza                 IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
      p_competenza_old             IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
      RETURN AFC_Error.t_error_number;
   FUNCTION is_modificabile_ok (
      p_id_oggetto                 number,
      p_oggetto                    varchar2,
      p_competenza                 varchar2,
      p_competenza_esclusiva       varchar2,
      p_competenza_old             varchar2,
      p_competenza_esclusiva_old   varchar2,
      p_utente                     varchar2,
      p_modulo                     varchar2,
      p_istanza                    varchar2,
      p_ruolo_accesso              varchar2)
      RETURN AFC_Error.t_error_number;
   FUNCTION is_inseribile_ok (
      p_id_oggetto                 number,
      p_oggetto                    varchar2,
      p_competenza                 varchar2,
      p_competenza_esclusiva       varchar2,
      p_competenza_old             varchar2,
      p_competenza_esclusiva_old   varchar2)
      RETURN AFC_Error.t_error_number;
   FUNCTION is_inseribile_ok (
      p_utente                     varchar2,
      p_oggetto                    varchar2,
      p_id_oggetto_padre           number,
      p_competenza                 varchar2,
      p_competenza_esclusiva       varchar2,
      p_modulo                     varchar2,
      p_istanza                    varchar2,
      p_ruolo_accesso              varchar2)
      RETURN AFC_Error.t_error_number;
      function get_rows
( p_QBE  in number default 0
, p_other_condition in varchar2 default null
, p_order_by in varchar2 default null
, p_extra_columns in varchar2 default null
, p_extra_condition in varchar2 default null
, p_id_anagrafica  in varchar2 default null
, p_ni  in varchar2 default null
, p_dal  in varchar2 default null
, p_al  in varchar2 default null
, p_cognome  in varchar2 default null
, p_nome  in varchar2 default null
, p_sesso  in varchar2 default null
, p_data_nas  in varchar2 default null
, p_provincia_nas  in varchar2 default null
, p_comune_nas  in varchar2 default null
, p_luogo_nas  in varchar2 default null
, p_codice_fiscale  in varchar2 default null
, p_codice_fiscale_estero  in varchar2 default null
, p_partita_iva  in varchar2 default null
, p_cittadinanza  in varchar2 default null
, p_gruppo_ling  in varchar2 default null
, p_competenza  in varchar2 default null
, p_competenza_esclusiva  in varchar2 default null
, p_tipo_soggetto  in varchar2 default null
, p_stato_cee  in varchar2 default null
, p_partita_iva_cee  in varchar2 default null
, p_fine_validita  in varchar2 default null
, p_stato_soggetto  in varchar2 default null
, p_denominazione  in varchar2 default null
, p_note  in varchar2 default null
, p_version  in varchar2 default null
, p_utente  in varchar2 default null
, p_data_agg  in varchar2 default null
) return AFC.t_ref_cursor;
procedure ANAGRAFICI_PI
(new_provincia_nas IN number,
 new_comune_nas IN number,
 new_tipo_soggetto IN varchar)
 ;
PROCEDURE ANAGRAFICI_Pu
(  old_ni IN NUMBER
 , old_dal IN DATE
 , old_provincia_nas IN NUMBER
 , old_comune_nas IN NUMBER
 , old_tipo_soggetto IN VARCHAR
 , new_ni IN NUMBER
 , new_dal IN DATE
 , new_provincia_nas IN NUMBER
 , new_comune_nas IN NUMBER
 , new_tipo_soggetto IN VARCHAR
);
procedure ANAGRAFICI_PD
(old_ni IN number,
 old_dal IN date,
 old_al IN date)
 ;
 PROCEDURE ANAGRAFICI_RRI
( p_ni         IN NUMBER
, p_dal        IN DATE
, p_competenza IN VARCHAR2
, p_competenza_esclusiva IN VARCHAR2
, p_cognome    IN VARCHAR2
, p_nome       IN VARCHAR2
);
FUNCTION CONTA_NI_ANAGRAFICI_DAL_AL (p_ni NUMBER, p_dal date, p_al date)
   RETURN NUMBER;
FUNCTION conta_ni_anagrafici (p_ni NUMBER)
   RETURN NUMBER;
FUNCTION get_soggetto_cf (p_cf varchar2)  --#54239
   RETURN NUMBER;
FUNCTION get_soggetti_denominazione_cr
   (
      p_denominazione_ricerca   varchar2
   ) RETURN integer;

FUNCTION get_soggetti_per_denominazione
   (
      p_denominazione_ricerca   varchar2
    , p_offset in number default null
    , p_limit in number default null
   ) RETURN afc.t_ref_cursor ;

   FUNCTION get_is_modificabile (
      p_tabella                    IN varchar2,
      p_competenza                 IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
      p_competenza_old             IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE,
      p_utente_agg                 IN varchar2,
      p_ruolo_accesso              IN varchar2,
      p_id_record                  IN number)
      RETURN varchar2;
FUNCTION controllo_se_ni_in_struttura(p_ni number)
  RETURN number;


FUNCTION get_tipo_struttura(p_ni number)
  RETURN VARCHAR2;

   FUNCTION ESTRAI_STORICO
    ( P_NI IN NUMBER)
    RETURN CLOB;
      function get_denominazione_ricerca
    (p_ni   in anagrafici.ni%type
    ,p_dal  in anagrafici.dal%type
    ) return varchar2 ;

    PROCEDURE allinea_anagrafica_amm_da_ipa (
      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
      p_comune_nas              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
      p_luogo_nas               IN ANAGRAFICI.luogo_nas%TYPE DEFAULT NULL,
      p_codice_fiscale          IN ANAGRAFICI.codice_fiscale%TYPE DEFAULT NULL,
      p_codice_fiscale_estero   IN ANAGRAFICI.codice_fiscale_estero%TYPE DEFAULT NULL,
      p_partita_iva             IN ANAGRAFICI.partita_iva%TYPE DEFAULT NULL,
      p_cittadinanza            IN ANAGRAFICI.cittadinanza%TYPE DEFAULT NULL,
      p_gruppo_ling             IN ANAGRAFICI.gruppo_ling%TYPE DEFAULT NULL,
      p_competenza              IN ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_competenza_esclusiva    IN ANAGRAFICI.competenza_esclusiva%TYPE DEFAULT NULL,
      p_tipo_soggetto           IN ANAGRAFICI.tipo_soggetto%TYPE DEFAULT NULL,
      p_stato_cee               IN ANAGRAFICI.stato_cee%TYPE DEFAULT NULL,
      p_partita_iva_cee         IN ANAGRAFICI.partita_iva_cee%TYPE DEFAULT NULL,
      p_fine_validita           IN ANAGRAFICI.fine_validita%TYPE DEFAULT NULL,
      p_stato_soggetto          IN ANAGRAFICI.stato_soggetto%TYPE DEFAULT 'U',
      p_note_anag               IN ANAGRAFICI.note%TYPE DEFAULT NULL,
      ----- dati residenza
      p_descrizione_residenza   in RECAPITI.descrizione%type default null,
      p_indirizzo_res           in RECAPITI.indirizzo%type default null,
      p_provincia_res           IN AD4_PROVINCE.sigla%TYPE DEFAULT NULL,
      p_comune_res              IN AD4_COMUNI.denominazione%TYPE DEFAULT NULL,
      p_cap_res                 in RECAPITI.cap%type default null,
      p_presso                  in RECAPITI.presso%type default null,
      p_importanza              in RECAPITI.importanza%type default null,
      ---- mail
      p_mail                    in CONTATTI.valore%type default null,
      p_note_mail               in CONTATTI.note%type default null,
      p_importanza_mail         in CONTATTI.importanza%type default null,
    ---- tel_res
      p_tel_res                 in CONTATTI.valore%type DEFAULT NULL,
      p_note_tel_res            in CONTATTI.note%type default null,
      p_importanza_tel_res      in CONTATTI.importanza%type default null,
      ---- fax_res
      p_fax_res                 in CONTATTI.valore%type default null,
      p_note_fax_res            in CONTATTI.note%type default null,
      p_importanza_fax_res      in CONTATTI.importanza%type default null,
      ---- dati generici
      p_utente                  IN ANAGRAFICI.utente%TYPE DEFAULT NULL,
      p_data_agg                IN ANAGRAFICI.data_agg%TYPE DEFAULT SYSDATE)  ;

 FUNCTION is_ultimo_dal (p_ni NUMBER, p_dal date)
        RETURN NUMBER;


END;
/

