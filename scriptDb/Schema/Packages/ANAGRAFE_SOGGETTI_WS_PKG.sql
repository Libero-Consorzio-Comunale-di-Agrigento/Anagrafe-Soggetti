CREATE OR REPLACE PACKAGE anagrafe_soggetti_ws_pkg IS /* MASTER_LINK */
/******************************************************************************
 NOME:        anagrafe_soggetti_ws_pkg
 DESCRIZIONE: Metodi per gestione di anagrafica per ws
 ANNOTAZIONI: .
 REVISIONI:   Template Revision: 1.1.
 <CODE>
 Rev.  Data       Autore  Descrizione.
 000   26/10/2017    Prima emissione.
 001   12/06/2018  SN      Parametro p_utente, competenza e competenza_esclusiva
                           acquisito dal web service
 002   26/04/2021  SN      Integrazioni funzioni per web service gestione contatti #49854
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione          CONSTANT afc.t_revision           := 'V1.02';
   -- Versione e revisione
   FUNCTION versione /* SLAVE_COPY */
      RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (versione, WNDS);


   function get_id_recapito_res
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number;

   function get_id_recapito_dom
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number;

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

fUNCTION ins_anag_dom_e_res_e_mail (
      -- dati anagrafica
--      p_id_anagrafica           IN ANAGRAFICI.id_anagrafica%TYPE DEFAULT NULL,
      p_ni                      IN ANAGRAFICI.ni%TYPE default NULL,
      p_dal                     IN ANAGRAFICI.dal%TYPE,
      p_al                      IN ANAGRAFICI.al%TYPE DEFAULT NULL,
      p_cognome                 IN ANAGRAFICI.cognome%TYPE,
      p_nome                    IN ANAGRAFICI.nome%TYPE DEFAULT NULL,
      p_sesso                   IN ANAGRAFICI.sesso%TYPE DEFAULT NULL,
      p_data_nas                IN ANAGRAFICI.data_nas%TYPE DEFAULT NULL,
      p_provincia_nas           IN anagrafici.provincia_nas%TYPE DEFAULT NULL,
      p_comune_nas              IN anagrafici.comune_nas%TYPE DEFAULT NULL,
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
    , p_indirizzo_res            in RECAPITI.indirizzo%type default null
    , p_provincia_res           IN recapiti.provincia%TYPE DEFAULT NULL
    , p_comune_res              IN recapiti.comune%TYPE DEFAULT NULL
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
    , p_provincia_dom           IN recapiti.provincia%TYPE DEFAULT NULL
    , p_comune_dom              IN recapiti.comune%TYPE DEFAULT NULL
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
      p_batch                      NUMBER DEFAULT 1           -- 0 = NON batch
                                                   )
      RETURN NUMBER;


   procedure ins_recapito_contatto
   (P_NI        IN NUMBER
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ,p_tipo_contatto in varchar2
   ,P_CONTATTO  IN VARCHAR2
   ,p_result  out number
   ,p_id_recapito out number
   ,p_id_contatto out number
   ,p_utente_aggiornamento     in varchar2 default null
   ,p_competenza              in varchar2 default null
   ,p_competenza_esclusiva     in varchar2 default null
   );

   FUNCTION CHECK_RECAPITO_CONTATTO
   (P_NI        IN NUMBER
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ,P_CONTATTO  IN VARCHAR2
   ,p_id_recapito out number
   ,p_id_contatto out number
   ) return number;

   procedure CHECK_RECAPITO_CONTATTO
   (P_NI        IN NUMBER
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ,P_CONTATTO  IN VARCHAR2
   ,p_result    out number
   ,p_id_recapito out number
   ,p_id_contatto out number
   );

   FUNCTION CHECK_RECAPITO
   (P_NI        IN NUMBER
   ,p_tipo_recapito in varchar2
   ,P_INDIRIZZO IN VARCHAR2
   ,P_PROVINCIA IN NUMBER
   ,P_COMUNE    IN NUMBER
   ) return number;

   function upd_recapito
   (p_id_recapito   in number
   ,p_ni            in number
   ,p_tipo_recapito in varchar2
   ,p_dal           in date
   ,p_al            in date
   ,p_descrizione   in varchar2
   ,p_indirizzo     in varchar2
   ,p_provincia     in number
   ,p_comune        in number
   ,p_cap           in varchar2
   ,p_presso        in varchar2
   ,p_importanza    in number
   ,p_utente_aggiornamento in varchar2 default null
   ,p_competenza              in varchar2 default null
   ,p_competenza_esclusiva     in varchar2 default null
   ) return number;

   function upd_contatto
   (p_id_contatto   in number
   ,p_ni            in number
   ,p_tipo_recapito in varchar2
   ,p_tipo_contatto in varchar2
   ,p_dal           in date
   ,p_al            in date
   ,p_valore        in varchar2
   ,p_note          in varchar2
   ,p_new_utente_aggiornamento in varchar2 default null
   ,p_competenza              in varchar2 default null
   ,p_competenza_esclusiva     in varchar2 default null
   ) return number;

  function GET_ID_CONTATTO_TEL_RES
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   )return number;

   function GET_ID_CONTATTO_FAX_RES
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number;

    function GET_ID_CONTATTO_TEL_DOM
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number;

   function GET_ID_CONTATTO_FAX_DOM
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number;

   function GET_ID_CONTATTO_INDIRIZZO_WEB
   (p_ni     IN ANAGRAFICI.ni%TYPE,
    p_dal    IN ANAGRAFICI.dal%TYPE
   ) return number;

END anagrafe_soggetti_ws_pkg;
/

