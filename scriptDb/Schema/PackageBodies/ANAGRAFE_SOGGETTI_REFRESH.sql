CREATE OR REPLACE PACKAGE BODY anagrafe_soggetti_refresh
IS
/******************************************************************************
 NOME:        anagrafe_soggetti_tpk
 DESCRIZIONE: Gestione tabella ANAGRAFE_SOGGETTI.
 ANNOTAZIONI: Inserite modifiche per refresh di eventuali SLAVE.
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   17/09/2008  snegroni  Prima emissione.
 001  14/11/2012   snegroni Aggiunto parametro per version per grails
******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '001';
   refresh            pls_integer := 1;
--------------------------------------------------------------------------------
   FUNCTION versione
      RETURN VARCHAR2
   IS
/******************************************************************************
 NOME:        versione
 DESCRIZIONE: Versione e revisione di distribuzione del package.
 RITORNA:     varchar2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilità del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;                             -- anagrafe_soggetti_tpk.versione
   procedure setrefreshon
   is
   begin
      refresh := 1;
   end;
   procedure setrefreshoff
   is
   begin
      refresh := 0;
   end;
--------------------------------------------------------------------------------
   FUNCTION pk (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN ANAGRAFE_SOGGETTI_TPK.t_pk
   IS
/******************************************************************************
 NOME:        PK
 DESCRIZIONE: Costruttore di un t_PK dati gli attributi della chiave
******************************************************************************/
      d_result   ANAGRAFE_SOGGETTI_TPK.t_pk;
   BEGIN
      RETURN ANAGRAFE_SOGGETTI_TPK.pk (p_ni, p_dal);
   END pk;                                         -- anagrafe_soggetti_tpk.PK
--------------------------------------------------------------------------------
   FUNCTION can_handle (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN NUMBER
   IS
/******************************************************************************
 NOME:        can_handle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: 1 se la chiave è manipolabile, 0 altrimenti.
 NOTE:        cfr. canHandle per ritorno valori boolean.
******************************************************************************/
   BEGIN
      RETURN ANAGRAFE_SOGGETTI_TPK.can_handle (p_ni, p_dal);
   END can_handle;                         -- anagrafe_soggetti_tpk.can_handle
--------------------------------------------------------------------------------
   FUNCTION canhandle (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN BOOLEAN
   IS
/******************************************************************************
 NOME:        canHandle
 DESCRIZIONE: La chiave specificata rispetta tutti i requisiti sugli attributi componenti.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: true se la chiave è manipolabile, false altrimenti.
 NOTE:        Wrapper boolean di can_handle (cfr. can_handle).
******************************************************************************/
   BEGIN
      RETURN afc.to_boolean (can_handle (p_ni => p_ni, p_dal => p_dal));
   END canhandle;                           -- anagrafe_soggetti_tpk.canHandle
--------------------------------------------------------------------------------
   FUNCTION exists_id (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN NUMBER
   IS
/******************************************************************************
 NOME:        exists_id
 DESCRIZIONE: Esistenza riga con chiave indicata.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: 1 se la riga esiste, 0 altrimenti.
 NOTE:        cfr. existsId per ritorno valori boolean.
******************************************************************************/
   BEGIN
      RETURN ANAGRAFE_SOGGETTI_TPK.exists_id (p_ni, p_dal);
   END exists_id;                           -- anagrafe_soggetti_tpk.exists_id
--------------------------------------------------------------------------------
   FUNCTION existsid (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN BOOLEAN
   IS
/******************************************************************************
 NOME:        existsId
 DESCRIZIONE: Esistenza riga con chiave indicata.
 NOTE:        Wrapper boolean di exists_id (cfr. exists_id).
******************************************************************************/
      d_result   CONSTANT BOOLEAN
                 := afc.to_boolean (exists_id (p_ni => p_ni, p_dal => p_dal));
   BEGIN
      RETURN d_result;
   END existsid;                             -- anagrafe_soggetti_tpk.existsId
--------------------------------------------------------------------------------
   PROCEDURE ins_tpk(
      p_ni                      IN   anagrafe_soggetti.ni%TYPE DEFAULT NULL
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
    , p_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT SYSDATE
    , p_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_al                      IN   anagrafe_soggetti.al%TYPE DEFAULT NULL
    , p_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_note                    IN   anagrafe_soggetti.note%TYPE DEFAULT NULL
    , p_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
   , p_version  in varchar2 default 0
   )
   IS
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.ins (p_ni
                               , p_dal
                               , p_cognome
                               , p_nome
                               , p_sesso
                               , p_data_nas
                               , p_provincia_nas
                               , p_comune_nas
                               , p_luogo_nas
                               , p_codice_fiscale
                               , p_codice_fiscale_estero
                               , p_partita_iva
                               , p_cittadinanza
                               , p_gruppo_ling
                               , p_indirizzo_res
                               , p_provincia_res
                               , p_comune_res
                               , p_cap_res
                               , p_tel_res
                               , p_fax_res
                               , p_presso
                               , p_indirizzo_dom
                               , p_provincia_dom
                               , p_comune_dom
                               , p_cap_dom
                               , p_tel_dom
                               , p_fax_dom
                               , p_utente
                               , p_data_agg
                               , p_competenza
                               , p_tipo_soggetto
                               , p_flag_trg
                               , p_stato_cee
                               , p_partita_iva_cee
                               , p_fine_validita
                               , p_al
                               , p_denominazione
                               , p_indirizzo_web
                               , p_note
                               , p_competenza_esclusiva
                               , p_version
                                );
   END ins_tpk;
   PROCEDURE ins_commit (
      p_ni                      IN   anagrafe_soggetti.ni%TYPE DEFAULT NULL
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
    , p_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT SYSDATE
    , p_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_al                      IN   anagrafe_soggetti.al%TYPE DEFAULT NULL
    , p_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_note                    IN   anagrafe_soggetti.note%TYPE DEFAULT NULL
    , p_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_version  in varchar2 default 0
   )
   IS
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
      pragma autonomous_transaction;
   BEGIN
      ins_tpk( p_ni
             , p_dal
             , p_cognome
             , p_nome
             , p_sesso
             , p_data_nas
             , p_provincia_nas
             , p_comune_nas
             , p_luogo_nas
             , p_codice_fiscale
             , p_codice_fiscale_estero
             , p_partita_iva
             , p_cittadinanza
             , p_gruppo_ling
             , p_indirizzo_res
             , p_provincia_res
             , p_comune_res
             , p_cap_res
             , p_tel_res
             , p_fax_res
             , p_presso
             , p_indirizzo_dom
             , p_provincia_dom
             , p_comune_dom
             , p_cap_dom
             , p_tel_dom
             , p_fax_dom
             , p_utente
             , p_data_agg
             , p_competenza
             , p_tipo_soggetto
             , p_flag_trg
             , p_stato_cee
             , p_partita_iva_cee
             , p_fine_validita
             , p_al
             , p_denominazione
             , p_indirizzo_web
             , p_note
             , p_competenza_esclusiva
             , p_version
              )
      ;
      commit;
   exception
      when others then
         rollback;
         raise;
   END ins_commit;
   PROCEDURE ins (
      p_ni                      IN   anagrafe_soggetti.ni%TYPE DEFAULT NULL
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
    , p_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT SYSDATE
    , p_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_al                      IN   anagrafe_soggetti.al%TYPE DEFAULT NULL
    , p_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_note                    IN   anagrafe_soggetti.note%TYPE DEFAULT NULL
    , p_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_version                 IN   anagrafe_soggetti.version%TYPE DEFAULT 0
   )
   IS
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
   BEGIN
      if anagrafe_soggetti_pkg.exists_slave = 0 or refresh = 0 then
         ins_tpk( p_ni
                , p_dal
                , p_cognome
                , p_nome
                , p_sesso
                , p_data_nas
                , p_provincia_nas
                , p_comune_nas
                , p_luogo_nas
                , p_codice_fiscale
                , p_codice_fiscale_estero
                , p_partita_iva
                , p_cittadinanza
                , p_gruppo_ling
                , p_indirizzo_res
                , p_provincia_res
                , p_comune_res
                , p_cap_res
                , p_tel_res
                , p_fax_res
                , p_presso
                , p_indirizzo_dom
                , p_provincia_dom
                , p_comune_dom
                , p_cap_dom
                , p_tel_dom
                , p_fax_dom
                , p_utente
                , p_data_agg
                , p_competenza
                , p_tipo_soggetto
                , p_flag_trg
                , p_stato_cee
                , p_partita_iva_cee
                , p_fine_validita
                , p_al
                , p_denominazione
                , p_indirizzo_web
                , p_note
                , p_competenza_esclusiva
                , p_version
                 )
         ;
      else
         begin
            ins_commit
                   ( p_ni
                   , p_dal
                   , p_cognome
                   , p_nome
                   , p_sesso
                   , p_data_nas
                   , p_provincia_nas
                   , p_comune_nas
                   , p_luogo_nas
                   , p_codice_fiscale
                   , p_codice_fiscale_estero
                   , p_partita_iva
                   , p_cittadinanza
                   , p_gruppo_ling
                   , p_indirizzo_res
                   , p_provincia_res
                   , p_comune_res
                   , p_cap_res
                   , p_tel_res
                   , p_fax_res
                   , p_presso
                   , p_indirizzo_dom
                   , p_provincia_dom
                   , p_comune_dom
                   , p_cap_dom
                   , p_tel_dom
                   , p_fax_dom
                   , p_utente
                   , p_data_agg
                   , p_competenza
                   , p_tipo_soggetto
                   , p_flag_trg
                   , p_stato_cee
                   , p_partita_iva_cee
                   , p_fine_validita
                   , p_al
                   , p_denominazione
                   , p_indirizzo_web
                   , p_note
                   , p_competenza_esclusiva
                   , p_version
                    )
            ;
            anagrafe_soggetti_pkg.refresh_slave;
         exception
            when others then
               raise;
         end;
      end if;
   END ins;                                       -- anagrafe_soggetti_tpk.ins
--------------------------------------------------------------------------------
   PROCEDURE upd_tpk(
      p_check_old                   IN   INTEGER DEFAULT 0
    , p_new_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_old_ni                      IN   anagrafe_soggetti.ni%TYPE
            DEFAULT NULL
    , p_new_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_old_dal                     IN   anagrafe_soggetti.dal%TYPE
            DEFAULT NULL
    , p_new_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_old_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_new_nome                    IN   anagrafe_soggetti.nome%TYPE
            DEFAULT NULL
    , p_old_nome                    IN   anagrafe_soggetti.nome%TYPE
            DEFAULT NULL
    , p_new_sesso                   IN   anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL
    , p_old_sesso                   IN   anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL
    , p_new_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_old_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_new_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_old_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_new_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_old_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_new_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_old_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_new_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_old_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_new_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_old_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_new_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_old_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_new_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_old_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_new_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_old_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_new_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_old_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_new_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_old_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_new_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_old_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_new_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_old_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_new_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_old_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_new_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_old_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_new_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_old_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_new_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_old_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_new_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_old_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_new_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_old_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_new_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_old_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_new_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_old_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_new_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_old_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_new_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_old_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_new_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_old_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_new_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_old_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_new_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_old_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_new_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_old_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_new_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_old_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_new_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_old_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_new_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_old_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_new_al                      IN   anagrafe_soggetti.al%TYPE
            DEFAULT NULL
    , p_old_al                      IN   anagrafe_soggetti.al%TYPE
            DEFAULT NULL
    , p_new_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_old_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_new_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_old_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_new_note                    IN   anagrafe_soggetti.note%TYPE
            DEFAULT NULL
    , p_old_note                    IN   anagrafe_soggetti.note%TYPE
            DEFAULT NULL
    , p_new_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_old_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_NEW_version  in ANAGRAFE_SOGGETTI.version%type default afc.default_null('ANAGRAFE_SOGGETTI.version')
    , p_OLD_version  in ANAGRAFE_SOGGETTI.version%type default null
   )
   IS
   BEGIN
      anagrafe_soggetti_tpk.upd (p_check_old
                               , p_new_ni
                               , p_old_ni
                               , p_new_dal
                               , p_old_dal
                               , p_new_cognome
                               , p_old_cognome
                               , p_new_nome
                               , p_old_nome
                               , p_new_sesso
                               , p_old_sesso
                               , p_new_data_nas
                               , p_old_data_nas
                               , p_new_provincia_nas
                               , p_old_provincia_nas
                               , p_new_comune_nas
                               , p_old_comune_nas
                               , p_new_luogo_nas
                               , p_old_luogo_nas
                               , p_new_codice_fiscale
                               , p_old_codice_fiscale
                               , p_new_codice_fiscale_estero
                               , p_old_codice_fiscale_estero
                               , p_new_partita_iva
                               , p_old_partita_iva
                               , p_new_cittadinanza
                               , p_old_cittadinanza
                               , p_new_gruppo_ling
                               , p_old_gruppo_ling
                               , p_new_indirizzo_res
                               , p_old_indirizzo_res
                               , p_new_provincia_res
                               , p_old_provincia_res
                               , p_new_comune_res
                               , p_old_comune_res
                               , p_new_cap_res
                               , p_old_cap_res
                               , p_new_tel_res
                               , p_old_tel_res
                               , p_new_fax_res
                               , p_old_fax_res
                               , p_new_presso
                               , p_old_presso
                               , p_new_indirizzo_dom
                               , p_old_indirizzo_dom
                               , p_new_provincia_dom
                               , p_old_provincia_dom
                               , p_new_comune_dom
                               , p_old_comune_dom
                               , p_new_cap_dom
                               , p_old_cap_dom
                               , p_new_tel_dom
                               , p_old_tel_dom
                               , p_new_fax_dom
                               , p_old_fax_dom
                               , p_new_utente
                               , p_old_utente
                               , p_new_data_agg
                               , p_old_data_agg
                               , p_new_competenza
                               , p_old_competenza
                               , p_new_tipo_soggetto
                               , p_old_tipo_soggetto
                               , p_new_flag_trg
                               , p_old_flag_trg
                               , p_new_stato_cee
                               , p_old_stato_cee
                               , p_new_partita_iva_cee
                               , p_old_partita_iva_cee
                               , p_new_fine_validita
                               , p_old_fine_validita
                               , p_new_al
                               , p_old_al
                               , p_new_denominazione
                               , p_old_denominazione
                               , p_new_indirizzo_web
                               , p_old_indirizzo_web
                               , p_new_note
                               , p_old_note
                               , p_new_competenza_esclusiva
                               , p_old_competenza_esclusiva
                               , p_new_version
                               , p_old_version
                                );
   END upd_tpk;
   PROCEDURE upd_commit(
      p_check_old                   IN   INTEGER DEFAULT 0
    , p_new_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_old_ni                      IN   anagrafe_soggetti.ni%TYPE
            DEFAULT NULL
    , p_new_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_old_dal                     IN   anagrafe_soggetti.dal%TYPE
            DEFAULT NULL
    , p_new_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_old_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_new_nome                    IN   anagrafe_soggetti.nome%TYPE
            DEFAULT NULL
    , p_old_nome                    IN   anagrafe_soggetti.nome%TYPE
            DEFAULT NULL
    , p_new_sesso                   IN   anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL
    , p_old_sesso                   IN   anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL
    , p_new_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_old_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_new_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_old_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_new_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_old_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_new_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_old_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_new_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_old_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_new_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_old_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_new_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_old_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_new_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_old_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_new_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_old_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_new_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_old_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_new_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_old_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_new_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_old_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_new_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_old_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_new_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_old_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_new_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_old_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_new_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_old_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_new_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_old_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_new_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_old_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_new_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_old_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_new_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_old_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_new_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_old_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_new_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_old_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_new_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_old_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_new_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_old_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_new_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_old_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_new_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_old_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_new_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_old_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_new_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_old_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_new_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_old_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_new_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_old_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_new_al                      IN   anagrafe_soggetti.al%TYPE
            DEFAULT NULL
    , p_old_al                      IN   anagrafe_soggetti.al%TYPE
            DEFAULT NULL
    , p_new_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_old_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_new_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_old_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_new_note                    IN   anagrafe_soggetti.note%TYPE
            DEFAULT NULL
    , p_old_note                    IN   anagrafe_soggetti.note%TYPE
            DEFAULT NULL
    , p_new_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_old_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_NEW_version  in ANAGRAFE_SOGGETTI.version%type default afc.default_null('ANAGRAFE_SOGGETTI.version')
    , p_OLD_version  in ANAGRAFE_SOGGETTI.version%type default null
   )
   IS
      pragma autonomous_transaction;
   BEGIN
      upd_tpk
         ( p_check_old
         , p_new_ni
         , p_old_ni
         , p_new_dal
         , p_old_dal
         , p_new_cognome
         , p_old_cognome
         , p_new_nome
         , p_old_nome
         , p_new_sesso
         , p_old_sesso
         , p_new_data_nas
         , p_old_data_nas
         , p_new_provincia_nas
         , p_old_provincia_nas
         , p_new_comune_nas
         , p_old_comune_nas
         , p_new_luogo_nas
         , p_old_luogo_nas
         , p_new_codice_fiscale
         , p_old_codice_fiscale
         , p_new_codice_fiscale_estero
         , p_old_codice_fiscale_estero
         , p_new_partita_iva
         , p_old_partita_iva
         , p_new_cittadinanza
         , p_old_cittadinanza
         , p_new_gruppo_ling
         , p_old_gruppo_ling
         , p_new_indirizzo_res
         , p_old_indirizzo_res
         , p_new_provincia_res
         , p_old_provincia_res
         , p_new_comune_res
         , p_old_comune_res
         , p_new_cap_res
         , p_old_cap_res
         , p_new_tel_res
         , p_old_tel_res
         , p_new_fax_res
         , p_old_fax_res
         , p_new_presso
         , p_old_presso
         , p_new_indirizzo_dom
         , p_old_indirizzo_dom
         , p_new_provincia_dom
         , p_old_provincia_dom
         , p_new_comune_dom
         , p_old_comune_dom
         , p_new_cap_dom
         , p_old_cap_dom
         , p_new_tel_dom
         , p_old_tel_dom
         , p_new_fax_dom
         , p_old_fax_dom
         , p_new_utente
         , p_old_utente
         , p_new_data_agg
         , p_old_data_agg
         , p_new_competenza
         , p_old_competenza
         , p_new_tipo_soggetto
         , p_old_tipo_soggetto
         , p_new_flag_trg
         , p_old_flag_trg
         , p_new_stato_cee
         , p_old_stato_cee
         , p_new_partita_iva_cee
         , p_old_partita_iva_cee
         , p_new_fine_validita
         , p_old_fine_validita
         , p_new_al
         , p_old_al
         , p_new_denominazione
         , p_old_denominazione
         , p_new_indirizzo_web
         , p_old_indirizzo_web
         , p_new_note
         , p_old_note
         , p_new_competenza_esclusiva
         , p_old_competenza_esclusiva
         , p_new_version
         , p_old_version
          );
      commit;
   exception
      when others then
         rollback;
         raise;
   END upd_commit;
   PROCEDURE upd(
      p_check_old                   IN   INTEGER DEFAULT 0
    , p_new_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_old_ni                      IN   anagrafe_soggetti.ni%TYPE
            DEFAULT NULL
    , p_new_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_old_dal                     IN   anagrafe_soggetti.dal%TYPE
            DEFAULT NULL
    , p_new_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_old_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_new_nome                    IN   anagrafe_soggetti.nome%TYPE
            DEFAULT NULL
    , p_old_nome                    IN   anagrafe_soggetti.nome%TYPE
            DEFAULT NULL
    , p_new_sesso                   IN   anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL
    , p_old_sesso                   IN   anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL
    , p_new_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_old_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_new_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_old_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_new_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_old_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_new_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_old_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_new_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_old_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_new_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_old_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_new_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_old_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_new_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_old_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_new_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_old_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_new_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_old_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_new_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_old_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_new_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_old_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_new_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_old_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_new_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_old_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_new_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_old_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_new_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_old_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_new_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_old_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_new_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_old_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_new_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_old_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_new_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_old_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_new_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_old_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_new_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_old_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_new_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_old_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_new_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_old_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_new_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_old_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_new_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_old_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_new_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_old_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_new_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_old_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_new_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_old_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_new_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_old_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_new_al                      IN   anagrafe_soggetti.al%TYPE
            DEFAULT NULL
    , p_old_al                      IN   anagrafe_soggetti.al%TYPE
            DEFAULT NULL
    , p_new_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_old_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_new_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_old_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_new_note                    IN   anagrafe_soggetti.note%TYPE
            DEFAULT NULL
    , p_old_note                    IN   anagrafe_soggetti.note%TYPE
            DEFAULT NULL
    , p_new_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_old_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_NEW_version  in ANAGRAFE_SOGGETTI.version%type default afc.default_null('ANAGRAFE_SOGGETTI.version')
    , p_OLD_version  in ANAGRAFE_SOGGETTI.version%type default null
   )
   IS
   BEGIN
--DBMS_OUTPUT.PUT_LINE(   anagrafe_soggetti_pkg.exists_slave||'...'|| refresh);
      if anagrafe_soggetti_pkg.exists_slave = 0 or refresh = 0 then
         upd_tpk
         ( p_check_old
         , p_new_ni
         , p_old_ni
         , p_new_dal
         , p_old_dal
         , p_new_cognome
         , p_old_cognome
         , p_new_nome
         , p_old_nome
         , p_new_sesso
         , p_old_sesso
         , p_new_data_nas
         , p_old_data_nas
         , p_new_provincia_nas
         , p_old_provincia_nas
         , p_new_comune_nas
         , p_old_comune_nas
         , p_new_luogo_nas
         , p_old_luogo_nas
         , p_new_codice_fiscale
         , p_old_codice_fiscale
         , p_new_codice_fiscale_estero
         , p_old_codice_fiscale_estero
         , p_new_partita_iva
         , p_old_partita_iva
         , p_new_cittadinanza
         , p_old_cittadinanza
         , p_new_gruppo_ling
         , p_old_gruppo_ling
         , p_new_indirizzo_res
         , p_old_indirizzo_res
         , p_new_provincia_res
         , p_old_provincia_res
         , p_new_comune_res
         , p_old_comune_res
         , p_new_cap_res
         , p_old_cap_res
         , p_new_tel_res
         , p_old_tel_res
         , p_new_fax_res
         , p_old_fax_res
         , p_new_presso
         , p_old_presso
         , p_new_indirizzo_dom
         , p_old_indirizzo_dom
         , p_new_provincia_dom
         , p_old_provincia_dom
         , p_new_comune_dom
         , p_old_comune_dom
         , p_new_cap_dom
         , p_old_cap_dom
         , p_new_tel_dom
         , p_old_tel_dom
         , p_new_fax_dom
         , p_old_fax_dom
         , p_new_utente
         , p_old_utente
         , p_new_data_agg
         , p_old_data_agg
         , p_new_competenza
         , p_old_competenza
         , p_new_tipo_soggetto
         , p_old_tipo_soggetto
         , p_new_flag_trg
         , p_old_flag_trg
         , p_new_stato_cee
         , p_old_stato_cee
         , p_new_partita_iva_cee
         , p_old_partita_iva_cee
         , p_new_fine_validita
         , p_old_fine_validita
         , p_new_al
         , p_old_al
         , p_new_denominazione
         , p_old_denominazione
         , p_new_indirizzo_web
         , p_old_indirizzo_web
         , p_new_note
         , p_old_note
         , p_new_competenza_esclusiva
         , p_old_competenza_esclusiva
         , p_new_version
         , p_old_version
          );
      else
         begin
            upd_commit
            ( p_check_old
            , p_new_ni
            , p_old_ni
            , p_new_dal
            , p_old_dal
            , p_new_cognome
            , p_old_cognome
            , p_new_nome
            , p_old_nome
            , p_new_sesso
            , p_old_sesso
            , p_new_data_nas
            , p_old_data_nas
            , p_new_provincia_nas
            , p_old_provincia_nas
            , p_new_comune_nas
            , p_old_comune_nas
            , p_new_luogo_nas
            , p_old_luogo_nas
            , p_new_codice_fiscale
            , p_old_codice_fiscale
            , p_new_codice_fiscale_estero
            , p_old_codice_fiscale_estero
            , p_new_partita_iva
            , p_old_partita_iva
            , p_new_cittadinanza
            , p_old_cittadinanza
            , p_new_gruppo_ling
            , p_old_gruppo_ling
            , p_new_indirizzo_res
            , p_old_indirizzo_res
            , p_new_provincia_res
            , p_old_provincia_res
            , p_new_comune_res
            , p_old_comune_res
            , p_new_cap_res
            , p_old_cap_res
            , p_new_tel_res
            , p_old_tel_res
            , p_new_fax_res
            , p_old_fax_res
            , p_new_presso
            , p_old_presso
            , p_new_indirizzo_dom
            , p_old_indirizzo_dom
            , p_new_provincia_dom
            , p_old_provincia_dom
            , p_new_comune_dom
            , p_old_comune_dom
            , p_new_cap_dom
            , p_old_cap_dom
            , p_new_tel_dom
            , p_old_tel_dom
            , p_new_fax_dom
            , p_old_fax_dom
            , p_new_utente
            , p_old_utente
            , p_new_data_agg
            , p_old_data_agg
            , p_new_competenza
            , p_old_competenza
            , p_new_tipo_soggetto
            , p_old_tipo_soggetto
            , p_new_flag_trg
            , p_old_flag_trg
            , p_new_stato_cee
            , p_old_stato_cee
            , p_new_partita_iva_cee
            , p_old_partita_iva_cee
            , p_new_fine_validita
            , p_old_fine_validita
            , p_new_al
            , p_old_al
            , p_new_denominazione
            , p_old_denominazione
            , p_new_indirizzo_web
            , p_old_indirizzo_web
            , p_new_note
            , p_old_note
            , p_new_competenza_esclusiva
            , p_old_competenza_esclusiva
            , p_new_version
            , p_old_version
             );
             --DBMS_OUTPUT.PUT_LINE('refresh_slave: '||refresh);
            anagrafe_soggetti_pkg.refresh_slave;
         exception
            when others then
               raise;
         end;
      end if;
   END upd;
--------------------------------------------------------------------------------
   PROCEDURE upd_column (
      p_ni              IN   anagrafe_soggetti.ni%TYPE
    , p_dal             IN   anagrafe_soggetti.dal%TYPE
    , p_column          IN   VARCHAR2
    , p_value           IN   VARCHAR2 DEFAULT NULL
    , p_literal_value   IN   NUMBER DEFAULT 1
   )
   IS
/******************************************************************************
 NOME:        upd_column
 DESCRIZIONE: Aggiornamento del campo p_column col valore p_value.
 PARAMETRI:   p_column:        identificatore del campo da aggiornare.
              p_value:         valore da modificare.
              p_literal_value: indica se il valore è un stringa e non un numero
                               o una funzione.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.UPD_COLUMN (p_ni
                                      , p_dal
                                      , p_column
                                      , p_value
                                      , p_literal_value
                                       );
   END upd_column;                         -- anagrafe_soggetti_tpk.upd_column
--------------------------------------------------------------------------------
   PROCEDURE upd_column (
      p_ni       IN   anagrafe_soggetti.ni%TYPE
    , p_dal      IN   anagrafe_soggetti.dal%TYPE
    , p_column   IN   VARCHAR2
    , p_value    IN   DATE
   )
   IS
/******************************************************************************
 NOME:        upd_column
 DESCRIZIONE: Aggiornamento del campo p_column col valore p_value.
 NOTE:        Richiama se stessa con il parametro date convertito in stringa.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.UPD_COLUMN (p_ni, p_dal, p_column, p_value);
   END upd_column;                         -- anagrafe_soggetti_tpk.upd_column
--------------------------------------------------------------------------------
   PROCEDURE del_tpk(
      p_check_old               IN   INTEGER DEFAULT 0
    , p_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
    , p_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_al                      IN   anagrafe_soggetti.al%TYPE DEFAULT NULL
    , p_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_note                    IN   anagrafe_soggetti.note%TYPE DEFAULT NULL
    , p_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_version  in anagrafe_soggetti.version%type
   )
   IS
   BEGIN
      anagrafe_soggetti_tpk.del (p_check_old
                               , p_ni
                               , p_dal
                               , p_cognome
                               , p_nome
                               , p_sesso
                               , p_data_nas
                               , p_provincia_nas
                               , p_comune_nas
                               , p_luogo_nas
                               , p_codice_fiscale
                               , p_codice_fiscale_estero
                               , p_partita_iva
                               , p_cittadinanza
                               , p_gruppo_ling
                               , p_indirizzo_res
                               , p_provincia_res
                               , p_comune_res
                               , p_cap_res
                               , p_tel_res
                               , p_fax_res
                               , p_presso
                               , p_indirizzo_dom
                               , p_provincia_dom
                               , p_comune_dom
                               , p_cap_dom
                               , p_tel_dom
                               , p_fax_dom
                               , p_utente
                               , p_data_agg
                               , p_competenza
                               , p_tipo_soggetto
                               , p_flag_trg
                               , p_stato_cee
                               , p_partita_iva_cee
                               , p_fine_validita
                               , p_al
                               , p_denominazione
                               , p_indirizzo_web
                               , p_note
                               , p_competenza_esclusiva
                               , p_version
                                );
   END del_tpk;
   PROCEDURE del_commit(
      p_check_old               IN   INTEGER DEFAULT 0
    , p_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
    , p_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_al                      IN   anagrafe_soggetti.al%TYPE DEFAULT NULL
    , p_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_note                    IN   anagrafe_soggetti.note%TYPE DEFAULT NULL
    , p_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_version  in anagrafe_soggetti.version%type default null
   )
   IS
      pragma autonomous_transaction;
   BEGIN
      del_tpk
         ( p_check_old
         , p_ni
         , p_dal
         , p_cognome
         , p_nome
         , p_sesso
         , p_data_nas
         , p_provincia_nas
         , p_comune_nas
         , p_luogo_nas
         , p_codice_fiscale
         , p_codice_fiscale_estero
         , p_partita_iva
         , p_cittadinanza
         , p_gruppo_ling
         , p_indirizzo_res
         , p_provincia_res
         , p_comune_res
         , p_cap_res
         , p_tel_res
         , p_fax_res
         , p_presso
         , p_indirizzo_dom
         , p_provincia_dom
         , p_comune_dom
         , p_cap_dom
         , p_tel_dom
         , p_fax_dom
         , p_utente
         , p_data_agg
         , p_competenza
         , p_tipo_soggetto
         , p_flag_trg
         , p_stato_cee
         , p_partita_iva_cee
         , p_fine_validita
         , p_al
         , p_denominazione
         , p_indirizzo_web
         , p_note
         , p_competenza_esclusiva
         , p_version
          );
      commit;
   exception
      when others then
         rollback;
         raise;
   END del_commit;
   PROCEDURE del (
      p_check_old               IN   INTEGER DEFAULT 0
    , p_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
            DEFAULT NULL
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
    , p_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_provincia_nas           IN   anagrafe_soggetti.provincia_nas%TYPE
            DEFAULT NULL
    , p_comune_nas              IN   anagrafe_soggetti.comune_nas%TYPE
            DEFAULT NULL
    , p_luogo_nas               IN   anagrafe_soggetti.luogo_nas%TYPE
            DEFAULT NULL
    , p_codice_fiscale          IN   anagrafe_soggetti.codice_fiscale%TYPE
            DEFAULT NULL
    , p_codice_fiscale_estero   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE
            DEFAULT NULL
    , p_partita_iva             IN   anagrafe_soggetti.partita_iva%TYPE
            DEFAULT NULL
    , p_cittadinanza            IN   anagrafe_soggetti.cittadinanza%TYPE
            DEFAULT NULL
    , p_gruppo_ling             IN   anagrafe_soggetti.gruppo_ling%TYPE
            DEFAULT NULL
    , p_indirizzo_res           IN   anagrafe_soggetti.indirizzo_res%TYPE
            DEFAULT NULL
    , p_provincia_res           IN   anagrafe_soggetti.provincia_res%TYPE
            DEFAULT NULL
    , p_comune_res              IN   anagrafe_soggetti.comune_res%TYPE
            DEFAULT NULL
    , p_cap_res                 IN   anagrafe_soggetti.cap_res%TYPE
            DEFAULT NULL
    , p_tel_res                 IN   anagrafe_soggetti.tel_res%TYPE
            DEFAULT NULL
    , p_fax_res                 IN   anagrafe_soggetti.fax_res%TYPE
            DEFAULT NULL
    , p_presso                  IN   anagrafe_soggetti.presso%TYPE
            DEFAULT NULL
    , p_indirizzo_dom           IN   anagrafe_soggetti.indirizzo_dom%TYPE
            DEFAULT NULL
    , p_provincia_dom           IN   anagrafe_soggetti.provincia_dom%TYPE
            DEFAULT NULL
    , p_comune_dom              IN   anagrafe_soggetti.comune_dom%TYPE
            DEFAULT NULL
    , p_cap_dom                 IN   anagrafe_soggetti.cap_dom%TYPE
            DEFAULT NULL
    , p_tel_dom                 IN   anagrafe_soggetti.tel_dom%TYPE
            DEFAULT NULL
    , p_fax_dom                 IN   anagrafe_soggetti.fax_dom%TYPE
            DEFAULT NULL
    , p_utente                  IN   anagrafe_soggetti.utente%TYPE
            DEFAULT NULL
    , p_data_agg                IN   anagrafe_soggetti.data_agg%TYPE
            DEFAULT NULL
    , p_competenza              IN   anagrafe_soggetti.competenza%TYPE
            DEFAULT NULL
    , p_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
            DEFAULT NULL
    , p_flag_trg                IN   anagrafe_soggetti.flag_trg%TYPE
            DEFAULT NULL
    , p_stato_cee               IN   anagrafe_soggetti.stato_cee%TYPE
            DEFAULT NULL
    , p_partita_iva_cee         IN   anagrafe_soggetti.partita_iva_cee%TYPE
            DEFAULT NULL
    , p_fine_validita           IN   anagrafe_soggetti.fine_validita%TYPE
            DEFAULT NULL
    , p_al                      IN   anagrafe_soggetti.al%TYPE DEFAULT NULL
    , p_denominazione           IN   anagrafe_soggetti.denominazione%TYPE
            DEFAULT NULL
    , p_indirizzo_web           IN   anagrafe_soggetti.indirizzo_web%TYPE
            DEFAULT NULL
    , p_note                    IN   anagrafe_soggetti.note%TYPE DEFAULT NULL
    , p_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_version                 IN   anagrafe_soggetti.version%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        del
 DESCRIZIONE: Cancellazione della riga indicata.
 PARAMETRI:   Chiavi e attributi della table.
              p_check_OLD: 0, ricerca senza controllo su attributi precedenti
                           1, ricerca con controllo anche su attributi precedenti.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
******************************************************************************/
   BEGIN
      if anagrafe_soggetti_pkg.exists_slave = 0 or refresh = 0 then
         del_tpk
            ( p_check_old
            , p_ni
            , p_dal
            , p_cognome
            , p_nome
            , p_sesso
            , p_data_nas
            , p_provincia_nas
            , p_comune_nas
            , p_luogo_nas
            , p_codice_fiscale
            , p_codice_fiscale_estero
            , p_partita_iva
            , p_cittadinanza
            , p_gruppo_ling
            , p_indirizzo_res
            , p_provincia_res
            , p_comune_res
            , p_cap_res
            , p_tel_res
            , p_fax_res
            , p_presso
            , p_indirizzo_dom
            , p_provincia_dom
            , p_comune_dom
            , p_cap_dom
            , p_tel_dom
            , p_fax_dom
            , p_utente
            , p_data_agg
            , p_competenza
            , p_tipo_soggetto
            , p_flag_trg
            , p_stato_cee
            , p_partita_iva_cee
            , p_fine_validita
            , p_al
            , p_denominazione
            , p_indirizzo_web
            , p_note
            , p_competenza_esclusiva
            , p_version
             );
      else
         begin
            del_commit
               ( p_check_old
               , p_ni
               , p_dal
               , p_cognome
               , p_nome
               , p_sesso
               , p_data_nas
               , p_provincia_nas
               , p_comune_nas
               , p_luogo_nas
               , p_codice_fiscale
               , p_codice_fiscale_estero
               , p_partita_iva
               , p_cittadinanza
               , p_gruppo_ling
               , p_indirizzo_res
               , p_provincia_res
               , p_comune_res
               , p_cap_res
               , p_tel_res
               , p_fax_res
               , p_presso
               , p_indirizzo_dom
               , p_provincia_dom
               , p_comune_dom
               , p_cap_dom
               , p_tel_dom
               , p_fax_dom
               , p_utente
               , p_data_agg
               , p_competenza
               , p_tipo_soggetto
               , p_flag_trg
               , p_stato_cee
               , p_partita_iva_cee
               , p_fine_validita
               , p_al
               , p_denominazione
               , p_indirizzo_web
               , p_note
               , p_competenza_esclusiva
               , p_version
                );
            anagrafe_soggetti_pkg.refresh_slave;
         exception
            when others then
               raise;
         end;
      end if;
   END del;                                       -- anagrafe_soggetti_tpk.del
--------------------------------------------------------------------------------
   FUNCTION get_cognome (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.cognome%TYPE
   IS
/******************************************************************************
 NOME:        get_cognome
 DESCRIZIONE: Getter per attributo cognome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cognome%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_cognome (p_ni, p_dal);
   END get_cognome;                       -- anagrafe_soggetti_tpk.get_cognome
--------------------------------------------------------------------------------
   FUNCTION get_nome (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.nome%TYPE
   IS
/******************************************************************************
 NOME:        get_nome
 DESCRIZIONE: Getter per attributo nome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.nome%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_nome (p_ni, p_dal);
   END get_nome;                             -- anagrafe_soggetti_tpk.get_nome
--------------------------------------------------------------------------------
   FUNCTION get_sesso (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.sesso%TYPE
   IS
/******************************************************************************
 NOME:        get_sesso
 DESCRIZIONE: Getter per attributo sesso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.sesso%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_sesso (p_ni, p_dal);
   END get_sesso;                           -- anagrafe_soggetti_tpk.get_sesso
--------------------------------------------------------------------------------
   FUNCTION get_data_nas (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.data_nas%TYPE
   IS
/******************************************************************************
 NOME:        get_data_nas
 DESCRIZIONE: Getter per attributo data_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.data_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_data_nas (p_ni, p_dal);
   END get_data_nas;                     -- anagrafe_soggetti_tpk.get_data_nas
--------------------------------------------------------------------------------
   FUNCTION get_provincia_nas (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.provincia_nas%TYPE
   IS
/******************************************************************************
 NOME:        get_provincia_nas
 DESCRIZIONE: Getter per attributo provincia_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.provincia_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_provincia_nas (p_ni, p_dal);
   END get_provincia_nas;           -- anagrafe_soggetti_tpk.get_provincia_nas
--------------------------------------------------------------------------------
   FUNCTION get_comune_nas (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.comune_nas%TYPE
   IS
/******************************************************************************
 NOME:        get_comune_nas
 DESCRIZIONE: Getter per attributo comune_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.comune_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_comune_nas (p_ni, p_dal);
   END get_comune_nas;                 -- anagrafe_soggetti_tpk.get_comune_nas
--------------------------------------------------------------------------------
   FUNCTION get_luogo_nas (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.luogo_nas%TYPE
   IS
/******************************************************************************
 NOME:        get_luogo_nas
 DESCRIZIONE: Getter per attributo luogo_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.luogo_nas%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_luogo_nas (p_ni, p_dal);
   END get_luogo_nas;                   -- anagrafe_soggetti_tpk.get_luogo_nas
--------------------------------------------------------------------------------
   FUNCTION get_codice_fiscale (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.codice_fiscale%TYPE
   IS
/******************************************************************************
 NOME:        get_codice_fiscale
 DESCRIZIONE: Getter per attributo codice_fiscale di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.codice_fiscale%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_codice_fiscale (p_ni, p_dal);
   END get_codice_fiscale;         -- anagrafe_soggetti_tpk.get_codice_fiscale
--------------------------------------------------------------------------------
   FUNCTION get_codice_fiscale_estero (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.codice_fiscale_estero%TYPE
   IS
/******************************************************************************
 NOME:        get_codice_fiscale_estero
 DESCRIZIONE: Getter per attributo codice_fiscale_estero di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.codice_fiscale_estero%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_codice_fiscale_estero (p_ni, p_dal);
   END get_codice_fiscale_estero;
                            -- anagrafe_soggetti_tpk.get_codice_fiscale_estero
--------------------------------------------------------------------------------
   FUNCTION get_partita_iva (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.partita_iva%TYPE
   IS
/******************************************************************************
 NOME:        get_partita_iva
 DESCRIZIONE: Getter per attributo partita_iva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.partita_iva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_partita_iva (p_ni, p_dal);
   END get_partita_iva;               -- anagrafe_soggetti_tpk.get_partita_iva
--------------------------------------------------------------------------------
   FUNCTION get_cittadinanza (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.cittadinanza%TYPE
   IS
/******************************************************************************
 NOME:        get_cittadinanza
 DESCRIZIONE: Getter per attributo cittadinanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cittadinanza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_cittadinanza (p_ni, p_dal);
   END get_cittadinanza;             -- anagrafe_soggetti_tpk.get_cittadinanza
--------------------------------------------------------------------------------
   FUNCTION get_gruppo_ling (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.gruppo_ling%TYPE
   IS
/******************************************************************************
 NOME:        get_gruppo_ling
 DESCRIZIONE: Getter per attributo gruppo_ling di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.gruppo_ling%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_gruppo_ling (p_ni, p_dal);
   END;
--------------------------------------------------------------------------------
   FUNCTION get_indirizzo_res (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.indirizzo_res%TYPE
   IS
/******************************************************************************
 NOME:        get_indirizzo_res
 DESCRIZIONE: Getter per attributo indirizzo_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.indirizzo_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_indirizzo_res (p_ni, p_dal);
   end;
--------------------------------------------------------------------------------
   FUNCTION get_provincia_res (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.provincia_res%TYPE
   IS
/******************************************************************************
 NOME:        get_provincia_res
 DESCRIZIONE: Getter per attributo provincia_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.provincia_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_provincia_res (p_ni, p_dal);
   END get_provincia_res;           -- anagrafe_soggetti_tpk.get_provincia_res
--------------------------------------------------------------------------------
   FUNCTION get_comune_res (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.comune_res%TYPE
   IS
/******************************************************************************
 NOME:        get_comune_res
 DESCRIZIONE: Getter per attributo comune_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.comune_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_comune_res (p_ni, p_dal);
   END get_comune_res;                 -- anagrafe_soggetti_tpk.get_comune_res
--------------------------------------------------------------------------------
   FUNCTION get_cap_res (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.cap_res%TYPE
   IS
/******************************************************************************
 NOME:        get_cap_res
 DESCRIZIONE: Getter per attributo cap_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cap_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_cap_res (p_ni, p_dal);
   END get_cap_res;                       -- anagrafe_soggetti_tpk.get_cap_res
--------------------------------------------------------------------------------
   FUNCTION get_tel_res (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.tel_res%TYPE
   IS
/******************************************************************************
 NOME:        get_tel_res
 DESCRIZIONE: Getter per attributo tel_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.tel_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_tel_res (p_ni, p_dal);
   END get_tel_res;                       -- anagrafe_soggetti_tpk.get_tel_res
--------------------------------------------------------------------------------
   FUNCTION get_fax_res (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.fax_res%TYPE
   IS
/******************************************************************************
 NOME:        get_fax_res
 DESCRIZIONE: Getter per attributo fax_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.fax_res%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_fax_res (p_ni, p_dal);
   END get_fax_res;                       -- anagrafe_soggetti_tpk.get_fax_res
--------------------------------------------------------------------------------
   FUNCTION get_presso (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.presso%TYPE
   IS
/******************************************************************************
 NOME:        get_presso
 DESCRIZIONE: Getter per attributo presso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.presso%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_presso (p_ni, p_dal);
   END get_presso;                         -- anagrafe_soggetti_tpk.get_presso
--------------------------------------------------------------------------------
   FUNCTION get_indirizzo_dom (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.indirizzo_dom%TYPE
   IS
/******************************************************************************
 NOME:        get_indirizzo_dom
 DESCRIZIONE: Getter per attributo indirizzo_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.indirizzo_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_indirizzo_dom (p_ni, p_dal);
   END get_indirizzo_dom;           -- anagrafe_soggetti_tpk.get_indirizzo_dom
--------------------------------------------------------------------------------
   FUNCTION get_provincia_dom (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.provincia_dom%TYPE
   IS
/******************************************************************************
 NOME:        get_provincia_dom
 DESCRIZIONE: Getter per attributo provincia_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.provincia_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_provincia_dom (p_ni, p_dal);
   END get_provincia_dom;           -- anagrafe_soggetti_tpk.get_provincia_dom
--------------------------------------------------------------------------------
   FUNCTION get_comune_dom (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.comune_dom%TYPE
   IS
/******************************************************************************
 NOME:        get_comune_dom
 DESCRIZIONE: Getter per attributo comune_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.comune_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_comune_dom (p_ni, p_dal);
   END get_comune_dom;                 -- anagrafe_soggetti_tpk.get_comune_dom
--------------------------------------------------------------------------------
   FUNCTION get_cap_dom (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.cap_dom%TYPE
   IS
/******************************************************************************
 NOME:        get_cap_dom
 DESCRIZIONE: Getter per attributo cap_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.cap_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_cap_dom (p_ni, p_dal);
   END get_cap_dom;                       -- anagrafe_soggetti_tpk.get_cap_dom
--------------------------------------------------------------------------------
   FUNCTION get_tel_dom (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.tel_dom%TYPE
   IS
/******************************************************************************
 NOME:        get_tel_dom
 DESCRIZIONE: Getter per attributo tel_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.tel_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_tel_dom (p_ni, p_dal);
   END get_tel_dom;                       -- anagrafe_soggetti_tpk.get_tel_dom
--------------------------------------------------------------------------------
   FUNCTION get_fax_dom (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.fax_dom%TYPE
   IS
/******************************************************************************
 NOME:        get_fax_dom
 DESCRIZIONE: Getter per attributo fax_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.fax_dom%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_fax_dom (p_ni, p_dal);
   END get_fax_dom;                       -- anagrafe_soggetti_tpk.get_fax_dom
--------------------------------------------------------------------------------
   FUNCTION get_utente (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.utente%TYPE
   IS
/******************************************************************************
 NOME:        get_utente
 DESCRIZIONE: Getter per attributo utente di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.utente%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_utente (p_ni, p_dal);
   END get_utente;                         -- anagrafe_soggetti_tpk.get_utente
--------------------------------------------------------------------------------
   FUNCTION get_data_agg (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.data_agg%TYPE
   IS
/******************************************************************************
 NOME:        get_data_agg
 DESCRIZIONE: Getter per attributo data_agg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.data_agg%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_data_agg (p_ni, p_dal);
   END get_data_agg;                     -- anagrafe_soggetti_tpk.get_data_agg
--------------------------------------------------------------------------------
   FUNCTION get_competenza (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.competenza%TYPE
   IS
/******************************************************************************
 NOME:        get_competenza
 DESCRIZIONE: Getter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.competenza%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_competenza (p_ni, p_dal);
   END get_competenza;                 -- anagrafe_soggetti_tpk.get_competenza
--------------------------------------------------------------------------------
   FUNCTION get_tipo_soggetto (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.tipo_soggetto%TYPE
   IS
/******************************************************************************
 NOME:        get_tipo_soggetto
 DESCRIZIONE: Getter per attributo tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.tipo_soggetto%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_tipo_soggetto (p_ni, p_dal);
   END get_tipo_soggetto;           -- anagrafe_soggetti_tpk.get_tipo_soggetto
--------------------------------------------------------------------------------
   FUNCTION get_flag_trg (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.flag_trg%TYPE
   IS
/******************************************************************************
 NOME:        get_flag_trg
 DESCRIZIONE: Getter per attributo flag_trg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.flag_trg%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_flag_trg (p_ni, p_dal);
   END get_flag_trg;                     -- anagrafe_soggetti_tpk.get_flag_trg
--------------------------------------------------------------------------------
   FUNCTION get_stato_cee (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.stato_cee%TYPE
   IS
/******************************************************************************
 NOME:        get_stato_cee
 DESCRIZIONE: Getter per attributo stato_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.stato_cee%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_stato_cee (p_ni, p_dal);
   END get_stato_cee;                   -- anagrafe_soggetti_tpk.get_stato_cee
--------------------------------------------------------------------------------
   FUNCTION get_partita_iva_cee (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.partita_iva_cee%TYPE
   IS
/******************************************************************************
 NOME:        get_partita_iva_cee
 DESCRIZIONE: Getter per attributo partita_iva_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.partita_iva_cee%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_partita_iva_cee (p_ni, p_dal);
   END get_partita_iva_cee;       -- anagrafe_soggetti_tpk.get_partita_iva_cee
--------------------------------------------------------------------------------
   FUNCTION get_fine_validita (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.fine_validita%TYPE
   IS
/******************************************************************************
 NOME:        get_fine_validita
 DESCRIZIONE: Getter per attributo fine_validita di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.fine_validita%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_fine_validita (p_ni, p_dal);
   END get_fine_validita;           -- anagrafe_soggetti_tpk.get_fine_validita
--------------------------------------------------------------------------------
   FUNCTION get_al (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.al%TYPE
   IS
/******************************************************************************
 NOME:        get_al
 DESCRIZIONE: Getter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.al%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_al (p_ni, p_dal);
   END get_al;                                 -- anagrafe_soggetti_tpk.get_al
--------------------------------------------------------------------------------
   FUNCTION get_denominazione (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.denominazione%TYPE
   IS
/******************************************************************************
 NOME:        get_denominazione
 DESCRIZIONE: Getter per attributo denominazione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.denominazione%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_denominazione (p_ni, p_dal);
   END get_denominazione;           -- anagrafe_soggetti_tpk.get_denominazione
--------------------------------------------------------------------------------
   FUNCTION get_indirizzo_web (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.indirizzo_web%TYPE
   IS
/******************************************************************************
 NOME:        get_indirizzo_web
 DESCRIZIONE: Getter per attributo indirizzo_web di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.indirizzo_web%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_indirizzo_web (p_ni, p_dal);
   END get_indirizzo_web;           -- anagrafe_soggetti_tpk.get_indirizzo_web
--------------------------------------------------------------------------------
   FUNCTION get_note (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.note%TYPE
   IS
/******************************************************************************
 NOME:        get_note
 DESCRIZIONE: Getter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.note%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_note (p_ni, p_dal);
   END get_note;                             -- anagrafe_soggetti_tpk.get_note
--------------------------------------------------------------------------------
   FUNCTION get_competenza_esclusiva (
      p_ni    IN   anagrafe_soggetti.ni%TYPE
    , p_dal   IN   anagrafe_soggetti.dal%TYPE
   )
      RETURN anagrafe_soggetti.competenza_esclusiva%TYPE
   IS
/******************************************************************************
 NOME:        get_competenza_esclusiva
 DESCRIZIONE: Getter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.competenza_esclusiva%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_competenza_esclusiva (p_ni, p_dal);
   END get_competenza_esclusiva;
                             -- anagrafe_soggetti_tpk.get_competenza_esclusiva
--------------------------------------------------------------------------------
FUNCTION get_version
(
  p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
) RETURN ANAGRAFE_SOGGETTI.version%type
   IS
/******************************************************************************
 NOME:        get_version
 DESCRIZIONE: Getter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 RITORNA:     ANAGRAFE_SOGGETTI.version%type.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_version (p_ni, p_dal);
   END get_version;
                             -- anagrafe_soggetti_tpk.get_version
--------------------------------------------------------------------------------
   PROCEDURE set_ni (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.ni%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_ni
 DESCRIZIONE: Setter per attributo ni di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_ni (p_ni, p_dal, p_value);
   END set_ni;                                 -- anagrafe_soggetti_tpk.set_ni
--------------------------------------------------------------------------------
   PROCEDURE set_dal (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.dal%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_dal
 DESCRIZIONE: Setter per attributo dal di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_dal (p_ni, p_dal, p_value);
   END set_dal;                               -- anagrafe_soggetti_tpk.set_dal
--------------------------------------------------------------------------------
   PROCEDURE set_cognome (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.cognome%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_cognome
 DESCRIZIONE: Setter per attributo cognome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_ni (p_ni, p_dal, p_value);
   END set_cognome;                       -- anagrafe_soggetti_tpk.set_cognome
--------------------------------------------------------------------------------
   PROCEDURE set_nome (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_nome
 DESCRIZIONE: Setter per attributo nome di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_nome (p_ni, p_dal, p_value);
   END set_nome;                             -- anagrafe_soggetti_tpk.set_nome
--------------------------------------------------------------------------------
   PROCEDURE set_sesso (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_sesso
 DESCRIZIONE: Setter per attributo sesso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_sesso (p_ni, p_dal, p_value);
   END set_sesso;                           -- anagrafe_soggetti_tpk.set_sesso
--------------------------------------------------------------------------------
   PROCEDURE set_data_nas (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.data_nas%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_data_nas
 DESCRIZIONE: Setter per attributo data_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_data_nas (p_ni, p_dal, p_value);
   END set_data_nas;                     -- anagrafe_soggetti_tpk.set_data_nas
--------------------------------------------------------------------------------
   PROCEDURE set_provincia_nas (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.provincia_nas%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_provincia_nas
 DESCRIZIONE: Setter per attributo provincia_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_provincia_nas (p_ni, p_dal, p_value);
   END set_provincia_nas;           -- anagrafe_soggetti_tpk.set_provincia_nas
--------------------------------------------------------------------------------
   PROCEDURE set_comune_nas (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.comune_nas%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_comune_nas
 DESCRIZIONE: Setter per attributo comune_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_comune_nas (p_ni, p_dal, p_value);
   END set_comune_nas;                 -- anagrafe_soggetti_tpk.set_comune_nas
--------------------------------------------------------------------------------
   PROCEDURE set_luogo_nas (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.luogo_nas%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_luogo_nas
 DESCRIZIONE: Setter per attributo luogo_nas di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_luogo_nas (p_ni, p_dal, p_value);
   END set_luogo_nas;                   -- anagrafe_soggetti_tpk.set_luogo_nas
--------------------------------------------------------------------------------
   PROCEDURE set_codice_fiscale (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.codice_fiscale%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_codice_fiscale
 DESCRIZIONE: Setter per attributo codice_fiscale di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_codice_fiscale (p_ni, p_dal, p_value);
   END set_codice_fiscale;         -- anagrafe_soggetti_tpk.set_codice_fiscale
--------------------------------------------------------------------------------
   PROCEDURE set_codice_fiscale_estero (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.codice_fiscale_estero%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_codice_fiscale_estero
 DESCRIZIONE: Setter per attributo codice_fiscale_estero di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_codice_fiscale_estero (p_ni, p_dal, p_value);
   END set_codice_fiscale_estero;
                            -- anagrafe_soggetti_tpk.set_codice_fiscale_estero
--------------------------------------------------------------------------------
   PROCEDURE set_partita_iva (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.partita_iva%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_partita_iva
 DESCRIZIONE: Setter per attributo partita_iva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_partita_iva (p_ni, p_dal, p_value);
   END set_partita_iva;               -- anagrafe_soggetti_tpk.set_partita_iva
--------------------------------------------------------------------------------
   PROCEDURE set_cittadinanza (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.cittadinanza%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_cittadinanza
 DESCRIZIONE: Setter per attributo cittadinanza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_cittadinanza (p_ni, p_dal, p_value);
   END set_cittadinanza;             -- anagrafe_soggetti_tpk.set_cittadinanza
--------------------------------------------------------------------------------
   PROCEDURE set_gruppo_ling (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.gruppo_ling%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_gruppo_ling
 DESCRIZIONE: Setter per attributo gruppo_ling di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_gruppo_ling (p_ni, p_dal, p_value);
   END set_gruppo_ling;               -- anagrafe_soggetti_tpk.set_gruppo_ling
--------------------------------------------------------------------------------
   PROCEDURE set_indirizzo_res (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.indirizzo_res%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_indirizzo_res
 DESCRIZIONE: Setter per attributo indirizzo_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_indirizzo_res (p_ni, p_dal, p_value);
   END set_indirizzo_res;           -- anagrafe_soggetti_tpk.set_indirizzo_res
--------------------------------------------------------------------------------
   PROCEDURE set_provincia_res (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.provincia_res%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_provincia_res
 DESCRIZIONE: Setter per attributo provincia_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_provincia_res (p_ni, p_dal, p_value);
   END set_provincia_res;           -- anagrafe_soggetti_tpk.set_provincia_res
--------------------------------------------------------------------------------
   PROCEDURE set_comune_res (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.comune_res%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_comune_res
 DESCRIZIONE: Setter per attributo comune_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_comune_res (p_ni, p_dal, p_value);
   END set_comune_res;                 -- anagrafe_soggetti_tpk.set_comune_res
--------------------------------------------------------------------------------
   PROCEDURE set_cap_res (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.cap_res%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_cap_res
 DESCRIZIONE: Setter per attributo cap_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_cap_res (p_ni, p_dal, p_value);
   END set_cap_res;                       -- anagrafe_soggetti_tpk.set_cap_res
--------------------------------------------------------------------------------
   PROCEDURE set_tel_res (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.tel_res%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_tel_res
 DESCRIZIONE: Setter per attributo tel_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_tel_res (p_ni, p_dal, p_value);
   END set_tel_res;                       -- anagrafe_soggetti_tpk.set_tel_res
--------------------------------------------------------------------------------
   PROCEDURE set_fax_res (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.fax_res%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_fax_res
 DESCRIZIONE: Setter per attributo fax_res di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_fax_res (p_ni, p_dal, p_value);
   END set_fax_res;                       -- anagrafe_soggetti_tpk.set_fax_res
--------------------------------------------------------------------------------
   PROCEDURE set_presso (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.presso%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_presso
 DESCRIZIONE: Setter per attributo presso di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_presso (p_ni, p_dal, p_value);
   END set_presso;                         -- anagrafe_soggetti_tpk.set_presso
--------------------------------------------------------------------------------
   PROCEDURE set_indirizzo_dom (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.indirizzo_dom%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_indirizzo_dom
 DESCRIZIONE: Setter per attributo indirizzo_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_indirizzo_dom (p_ni, p_dal, p_value);
   END set_indirizzo_dom;           -- anagrafe_soggetti_tpk.set_indirizzo_dom
--------------------------------------------------------------------------------
   PROCEDURE set_provincia_dom (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.provincia_dom%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_provincia_dom
 DESCRIZIONE: Setter per attributo provincia_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_provincia_dom (p_ni, p_dal, p_value);
   END set_provincia_dom;           -- anagrafe_soggetti_tpk.set_provincia_dom
--------------------------------------------------------------------------------
   PROCEDURE set_comune_dom (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.comune_dom%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_comune_dom
 DESCRIZIONE: Setter per attributo comune_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_comune_dom (p_ni, p_dal, p_value);
   END set_comune_dom;                 -- anagrafe_soggetti_tpk.set_comune_dom
--------------------------------------------------------------------------------
   PROCEDURE set_cap_dom (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.cap_dom%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_cap_dom
 DESCRIZIONE: Setter per attributo cap_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_cap_dom (p_ni, p_dal, p_value);
   END set_cap_dom;                       -- anagrafe_soggetti_tpk.set_cap_dom
--------------------------------------------------------------------------------
   PROCEDURE set_tel_dom (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.tel_dom%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_tel_dom
 DESCRIZIONE: Setter per attributo tel_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_tel_dom (p_ni, p_dal, p_value);
   END set_tel_dom;                       -- anagrafe_soggetti_tpk.set_tel_dom
--------------------------------------------------------------------------------
   PROCEDURE set_fax_dom (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.fax_dom%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_fax_dom
 DESCRIZIONE: Setter per attributo fax_dom di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_fax_dom (p_ni, p_dal, p_value);
   END set_fax_dom;                       -- anagrafe_soggetti_tpk.set_fax_dom
--------------------------------------------------------------------------------
   PROCEDURE set_utente (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.utente%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_utente
 DESCRIZIONE: Setter per attributo utente di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_utente (p_ni, p_dal, p_value);
   END set_utente;                         -- anagrafe_soggetti_tpk.set_utente
--------------------------------------------------------------------------------
   PROCEDURE set_data_agg (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.data_agg%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_data_agg
 DESCRIZIONE: Setter per attributo data_agg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_data_agg (p_ni, p_dal, p_value);
   END set_data_agg;                     -- anagrafe_soggetti_tpk.set_data_agg
--------------------------------------------------------------------------------
   PROCEDURE set_competenza (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.competenza%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_competenza
 DESCRIZIONE: Setter per attributo competenza di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_competenza (p_ni, p_dal, p_value);
   END set_competenza;                 -- anagrafe_soggetti_tpk.set_competenza
--------------------------------------------------------------------------------
   PROCEDURE set_tipo_soggetto (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.tipo_soggetto%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_tipo_soggetto
 DESCRIZIONE: Setter per attributo tipo_soggetto di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_tipo_soggetto (p_ni, p_dal, p_value);
   END set_tipo_soggetto;           -- anagrafe_soggetti_tpk.set_tipo_soggetto
--------------------------------------------------------------------------------
   PROCEDURE set_flag_trg (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.flag_trg%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_flag_trg
 DESCRIZIONE: Setter per attributo flag_trg di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_flag_trg (p_ni, p_dal, p_value);
   END set_flag_trg;                     -- anagrafe_soggetti_tpk.set_flag_trg
--------------------------------------------------------------------------------
   PROCEDURE set_stato_cee (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.stato_cee%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_stato_cee
 DESCRIZIONE: Setter per attributo stato_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_stato_cee (p_ni, p_dal, p_value);
   END set_stato_cee;                   -- anagrafe_soggetti_tpk.set_stato_cee
--------------------------------------------------------------------------------
   PROCEDURE set_partita_iva_cee (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.partita_iva_cee%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_partita_iva_cee
 DESCRIZIONE: Setter per attributo partita_iva_cee di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_partita_iva_cee (p_ni, p_dal, p_value);
   END set_partita_iva_cee;       -- anagrafe_soggetti_tpk.set_partita_iva_cee
--------------------------------------------------------------------------------
   PROCEDURE set_fine_validita (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.fine_validita%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_fine_validita
 DESCRIZIONE: Setter per attributo fine_validita di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_fine_validita (p_ni, p_dal, p_value);
   END set_fine_validita;           -- anagrafe_soggetti_tpk.set_fine_validita
--------------------------------------------------------------------------------
   PROCEDURE set_al (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.al%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_al
 DESCRIZIONE: Setter per attributo al di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_al (p_ni, p_dal, p_value);
   END set_al;                                 -- anagrafe_soggetti_tpk.set_al
--------------------------------------------------------------------------------
   PROCEDURE set_denominazione (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.denominazione%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_denominazione
 DESCRIZIONE: Setter per attributo denominazione di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_denominazione (p_ni, p_dal, p_value);
   END set_denominazione;           -- anagrafe_soggetti_tpk.set_denominazione
--------------------------------------------------------------------------------
   PROCEDURE set_indirizzo_web (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.indirizzo_web%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_indirizzo_web
 DESCRIZIONE: Setter per attributo indirizzo_web di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_indirizzo_web (p_ni, p_dal, p_value);
   END set_indirizzo_web;           -- anagrafe_soggetti_tpk.set_indirizzo_web
--------------------------------------------------------------------------------
   PROCEDURE set_note (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.note%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_note
 DESCRIZIONE: Setter per attributo note di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_note (p_ni, p_dal, p_value);
   END set_note;                             -- anagrafe_soggetti_tpk.set_note
--------------------------------------------------------------------------------
   PROCEDURE set_competenza_esclusiva (
      p_ni      IN   anagrafe_soggetti.ni%TYPE
    , p_dal     IN   anagrafe_soggetti.dal%TYPE
    , p_value   IN   anagrafe_soggetti.competenza_esclusiva%TYPE DEFAULT NULL
   )
   IS
/******************************************************************************
 NOME:        set_competenza_esclusiva
 DESCRIZIONE: Setter per attributo competenza_esclusiva di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_competenza_esclusiva (p_ni, p_dal, p_value);
   END set_competenza_esclusiva;
                             -- anagrafe_soggetti_tpk.set_competenza_esclusiva
--------------------------------------------------------------------------------
-- Setter per attributo version di riga identificata da chiave
   procedure set_version
   (
     p_ni  in ANAGRAFE_SOGGETTI.ni%type
,p_dal  in ANAGRAFE_SOGGETTI.dal%type
   , p_value  in ANAGRAFE_SOGGETTI.version%type default null
   )
   IS
/******************************************************************************
 NOME:        set_version
 DESCRIZIONE: Setter per attributo version di riga identificata dalla chiave.
 PARAMETRI:   Attributi chiave.
 NOTE:        La riga identificata deve essere presente.
******************************************************************************/
   BEGIN
      anagrafe_soggetti_tpk.set_version (p_ni, p_dal, p_value);
   END set_version;
                             -- anagrafe_soggetti_tpk.set_version
--------------------------------------------------------------------------------
   FUNCTION get_rows (
      p_qbe                     IN   NUMBER DEFAULT 0
    , p_other_condition         IN   VARCHAR2 DEFAULT NULL
    , p_order_by                IN   VARCHAR2 DEFAULT NULL
    , p_extra_columns           IN   VARCHAR2 DEFAULT NULL
    , p_extra_condition         IN   VARCHAR2 DEFAULT NULL
    , p_ni                      IN   VARCHAR2 DEFAULT NULL
    , p_dal                     IN   VARCHAR2 DEFAULT NULL
    , p_cognome                 IN   VARCHAR2 DEFAULT NULL
    , p_nome                    IN   VARCHAR2 DEFAULT NULL
    , p_sesso                   IN   VARCHAR2 DEFAULT NULL
    , p_data_nas                IN   VARCHAR2 DEFAULT NULL
    , p_provincia_nas           IN   VARCHAR2 DEFAULT NULL
    , p_comune_nas              IN   VARCHAR2 DEFAULT NULL
    , p_luogo_nas               IN   VARCHAR2 DEFAULT NULL
    , p_codice_fiscale          IN   VARCHAR2 DEFAULT NULL
    , p_codice_fiscale_estero   IN   VARCHAR2 DEFAULT NULL
    , p_partita_iva             IN   VARCHAR2 DEFAULT NULL
    , p_cittadinanza            IN   VARCHAR2 DEFAULT NULL
    , p_gruppo_ling             IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_res           IN   VARCHAR2 DEFAULT NULL
    , p_provincia_res           IN   VARCHAR2 DEFAULT NULL
    , p_comune_res              IN   VARCHAR2 DEFAULT NULL
    , p_cap_res                 IN   VARCHAR2 DEFAULT NULL
    , p_tel_res                 IN   VARCHAR2 DEFAULT NULL
    , p_fax_res                 IN   VARCHAR2 DEFAULT NULL
    , p_presso                  IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_dom           IN   VARCHAR2 DEFAULT NULL
    , p_provincia_dom           IN   VARCHAR2 DEFAULT NULL
    , p_comune_dom              IN   VARCHAR2 DEFAULT NULL
    , p_cap_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_tel_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_fax_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_utente                  IN   VARCHAR2 DEFAULT NULL
    , p_data_agg                IN   VARCHAR2 DEFAULT NULL
    , p_competenza              IN   VARCHAR2 DEFAULT NULL
    , p_tipo_soggetto           IN   VARCHAR2 DEFAULT NULL
    , p_flag_trg                IN   VARCHAR2 DEFAULT NULL
    , p_stato_cee               IN   VARCHAR2 DEFAULT NULL
    , p_partita_iva_cee         IN   VARCHAR2 DEFAULT NULL
    , p_fine_validita           IN   VARCHAR2 DEFAULT NULL
    , p_al                      IN   VARCHAR2 DEFAULT NULL
    , p_denominazione           IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_web           IN   VARCHAR2 DEFAULT NULL
    , p_note                    IN   VARCHAR2 DEFAULT NULL
    , p_competenza_esclusiva    IN   VARCHAR2 DEFAULT NULL
    , p_version                 IN   VARCHAR2 DEFAULT NULL
   )
      RETURN afc.t_ref_cursor
   IS
/******************************************************************************
 NOME:        get_rows
 DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
 PARAMETRI:   p_QBE 0: se l'operatore da utilizzare nella where-condition è
quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition è
quello specificato per ogni attributo.
              p_other_condition: condizioni aggiuntive di base
              p_order_by: condizioni di ordinamento
              p_extra_columns: colonne aggiungere alla select
              p_extra_condition: condizioni aggiuntive
              Chiavi e attributi della table
 RITORNA:     Un ref_cursor che punta al risultato della query.
 NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
              l'operatore da utilizzare nella where-condition.
              In p_extra_columns e p_order_by non devono essere passati anche la
              virgola iniziale (per p_extra_columns) e la stringa 'order by' (per
              p_order_by)
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.get_rows (p_qbe
                                           , p_other_condition
                                           , p_order_by
                                           , p_extra_columns
                                           , p_extra_condition
                                           , p_ni
                                           , p_dal
                                           , p_cognome
                                           , p_nome
                                           , p_sesso
                                           , p_data_nas
                                           , p_provincia_nas
                                           , p_comune_nas
                                           , p_luogo_nas
                                           , p_codice_fiscale
                                           , p_codice_fiscale_estero
                                           , p_partita_iva
                                           , p_cittadinanza
                                           , p_gruppo_ling
                                           , p_indirizzo_res
                                           , p_provincia_res
                                           , p_comune_res
                                           , p_cap_res
                                           , p_tel_res
                                           , p_fax_res
                                           , p_presso
                                           , p_indirizzo_dom
                                           , p_provincia_dom
                                           , p_comune_dom
                                           , p_cap_dom
                                           , p_tel_dom
                                           , p_fax_dom
                                           , p_utente
                                           , p_data_agg
                                           , p_competenza
                                           , p_tipo_soggetto
                                           , p_flag_trg
                                           , p_stato_cee
                                           , p_partita_iva_cee
                                           , p_fine_validita
                                           , p_al
                                           , p_denominazione
                                           , p_indirizzo_web
                                           , p_note
                                           , p_competenza_esclusiva
                                           , p_version
                                            );
   END get_rows;                             -- anagrafe_soggetti_tpk.get_rows
--------------------------------------------------------------------------------
   FUNCTION count_rows (
      p_qbe                     IN   NUMBER DEFAULT 0
    , p_other_condition         IN   VARCHAR2 DEFAULT NULL
    , p_ni                      IN   VARCHAR2 DEFAULT NULL
    , p_dal                     IN   VARCHAR2 DEFAULT NULL
    , p_cognome                 IN   VARCHAR2 DEFAULT NULL
    , p_nome                    IN   VARCHAR2 DEFAULT NULL
    , p_sesso                   IN   VARCHAR2 DEFAULT NULL
    , p_data_nas                IN   VARCHAR2 DEFAULT NULL
    , p_provincia_nas           IN   VARCHAR2 DEFAULT NULL
    , p_comune_nas              IN   VARCHAR2 DEFAULT NULL
    , p_luogo_nas               IN   VARCHAR2 DEFAULT NULL
    , p_codice_fiscale          IN   VARCHAR2 DEFAULT NULL
    , p_codice_fiscale_estero   IN   VARCHAR2 DEFAULT NULL
    , p_partita_iva             IN   VARCHAR2 DEFAULT NULL
    , p_cittadinanza            IN   VARCHAR2 DEFAULT NULL
    , p_gruppo_ling             IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_res           IN   VARCHAR2 DEFAULT NULL
    , p_provincia_res           IN   VARCHAR2 DEFAULT NULL
    , p_comune_res              IN   VARCHAR2 DEFAULT NULL
    , p_cap_res                 IN   VARCHAR2 DEFAULT NULL
    , p_tel_res                 IN   VARCHAR2 DEFAULT NULL
    , p_fax_res                 IN   VARCHAR2 DEFAULT NULL
    , p_presso                  IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_dom           IN   VARCHAR2 DEFAULT NULL
    , p_provincia_dom           IN   VARCHAR2 DEFAULT NULL
    , p_comune_dom              IN   VARCHAR2 DEFAULT NULL
    , p_cap_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_tel_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_fax_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_utente                  IN   VARCHAR2 DEFAULT NULL
    , p_data_agg                IN   VARCHAR2 DEFAULT NULL
    , p_competenza              IN   VARCHAR2 DEFAULT NULL
    , p_tipo_soggetto           IN   VARCHAR2 DEFAULT NULL
    , p_flag_trg                IN   VARCHAR2 DEFAULT NULL
    , p_stato_cee               IN   VARCHAR2 DEFAULT NULL
    , p_partita_iva_cee         IN   VARCHAR2 DEFAULT NULL
    , p_fine_validita           IN   VARCHAR2 DEFAULT NULL
    , p_al                      IN   VARCHAR2 DEFAULT NULL
    , p_denominazione           IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_web           IN   VARCHAR2 DEFAULT NULL
    , p_note                    IN   VARCHAR2 DEFAULT NULL
    , p_competenza_esclusiva    IN   VARCHAR2 DEFAULT NULL
    , p_version                 IN   VARCHAR2 DEFAULT NULL
   )
      RETURN INTEGER
   IS
/******************************************************************************
 NOME:        count_rows
 DESCRIZIONE: Ritorna il numero di righe della tabella gli attributi delle quali
              rispettano i valori indicati.
 PARAMETRI:   p_other_condition
              p_QBE 0: se l'operatore da utilizzare nella where-condition è
quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition è
quello specificato per ogni attributo.
              Chiavi e attributi della table
 RITORNA:     Numero di righe che rispettano la selezione indicata.
******************************************************************************/
   BEGIN
      RETURN anagrafe_soggetti_tpk.count_rows (p_qbe
                                             , p_other_condition
                                             , p_ni
                                             , p_dal
                                             , p_cognome
                                             , p_nome
                                             , p_sesso
                                             , p_data_nas
                                             , p_provincia_nas
                                             , p_comune_nas
                                             , p_luogo_nas
                                             , p_codice_fiscale
                                             , p_codice_fiscale_estero
                                             , p_partita_iva
                                             , p_cittadinanza
                                             , p_gruppo_ling
                                             , p_indirizzo_res
                                             , p_provincia_res
                                             , p_comune_res
                                             , p_cap_res
                                             , p_tel_res
                                             , p_fax_res
                                             , p_presso
                                             , p_indirizzo_dom
                                             , p_provincia_dom
                                             , p_comune_dom
                                             , p_cap_dom
                                             , p_tel_dom
                                             , p_fax_dom
                                             , p_utente
                                             , p_data_agg
                                             , p_competenza
                                             , p_tipo_soggetto
                                             , p_flag_trg
                                             , p_stato_cee
                                             , p_partita_iva_cee
                                             , p_fine_validita
                                             , p_al
                                             , p_denominazione
                                             , p_indirizzo_web
                                             , p_note
                                             , p_competenza_esclusiva
                                             , p_version
                                              );
   END count_rows;
                -- anagrafe_soggetti_tpk.count_rows
--------------------------------------------------------------------------------
END anagrafe_soggetti_refresh;
/

