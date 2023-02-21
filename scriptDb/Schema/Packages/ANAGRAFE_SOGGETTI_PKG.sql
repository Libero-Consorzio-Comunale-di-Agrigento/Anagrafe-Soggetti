CREATE OR REPLACE PACKAGE anagrafe_soggetti_pkg IS /* MASTER_LINK */
/******************************************************************************
 NOME:        anagrafe_soggetti_pkg
 DESCRIZIONE: Gestione tabella anagrafe_soggetti.
 ANNOTAZIONI: .
 REVISIONI:   Template Revision: 1.1.
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    04/07/2007  VDAVALLI  Prima emissione.
 01    29/10/2008  Snegroni  Aggiunta init_ni
 02    23/11/2009  MMalferrari Aggiunta funzione init_ni
 03    28/11/2011  Snegroni Aggiunta is_competenza_ok
 04    05/12/2011  SNegroni Aggiunta scegli_fra_soggetti
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione          CONSTANT afc.t_revision           := 'V1.04';
   -- Versione e revisione
   FUNCTION versione /* SLAVE_COPY */
      RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (versione, WNDS);
   -- righe corrispondenti alla selezione indicata
   FUNCTION get_rows  /* SLAVE_COPY */
   (
      p_ni                      IN   VARCHAR2 DEFAULT NULL
    , p_dal                     IN   VARCHAR2 DEFAULT NULL
    , p_cognome                 IN   VARCHAR2 DEFAULT NULL
    , p_nome                    IN   VARCHAR2 DEFAULT NULL
    , p_sesso                   IN   VARCHAR2 DEFAULT NULL
    , p_data_nas                IN   VARCHAR2 DEFAULT NULL
    , p_sigla_provincia_nas     IN   VARCHAR2 DEFAULT NULL
    , p_descr_comune_nas        IN   VARCHAR2 DEFAULT NULL
    , p_luogo_nas               IN   VARCHAR2 DEFAULT NULL
    , p_codice_fiscale          IN   VARCHAR2 DEFAULT NULL
    , p_codice_fiscale_estero   IN   VARCHAR2 DEFAULT NULL
    , p_partita_iva             IN   VARCHAR2 DEFAULT NULL
    , p_cittadinanza            IN   VARCHAR2 DEFAULT NULL
    , p_gruppo_ling             IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_res           IN   VARCHAR2 DEFAULT NULL
    , p_sigla_provincia_res     IN   VARCHAR2 DEFAULT NULL
    , p_descr_comune_res        IN   VARCHAR2 DEFAULT NULL
    , p_cap_res                 IN   VARCHAR2 DEFAULT NULL
    , p_tel_res                 IN   VARCHAR2 DEFAULT NULL
    , p_fax_res                 IN   VARCHAR2 DEFAULT NULL
    , p_presso                  IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_dom           IN   VARCHAR2 DEFAULT NULL
    , p_sigla_provincia_dom     IN   VARCHAR2 DEFAULT NULL
    , p_descr_comune_dom        IN   VARCHAR2 DEFAULT NULL
    , p_cap_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_tel_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_fax_dom                 IN   VARCHAR2 DEFAULT NULL
    , p_utente                  IN   VARCHAR2 DEFAULT NULL
    , p_data_agg                IN   VARCHAR2 DEFAULT NULL
    , p_competenza              IN   VARCHAR2 DEFAULT NULL
    , p_competenza_esclusiva    IN   VARCHAR2 DEFAULT NULL
    , p_tipo_soggetto           IN   VARCHAR2 DEFAULT NULL
    , p_stato_cee               IN   VARCHAR2 DEFAULT NULL
    , p_partita_iva_cee         IN   VARCHAR2 DEFAULT NULL
    , p_fine_validita           IN   VARCHAR2 DEFAULT NULL
    , p_al                      IN   VARCHAR2 DEFAULT NULL
    , p_denominazione           IN   VARCHAR2 DEFAULT NULL
    , p_indirizzo_web           IN   VARCHAR2 DEFAULT NULL
    , p_note                    IN   VARCHAR2 DEFAULT NULL
    , p_other_condition         IN   VARCHAR2 DEFAULT NULL
    , p_qbe                     IN   NUMBER DEFAULT 0
   )
      RETURN afc.t_ref_cursor;
   PROCEDURE init_ni (
      p_ni   IN OUT   anagrafe_soggetti.ni%TYPE
   );
   FUNCTION init_ni RETURN NUMBER;
   PROCEDURE ins (
      p_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE
            DEFAULT NULL
    , p_data_nas                IN   anagrafe_soggetti.data_nas%TYPE
            DEFAULT NULL
    , p_sigla_provincia_nas     IN   ad4_province.sigla%TYPE DEFAULT NULL
    , p_descr_comune_nas        IN   ad4_comuni.denominazione%TYPE
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
    , p_sigla_provincia_res     IN   ad4_province.sigla%TYPE DEFAULT NULL
    , p_descr_comune_res        IN   ad4_comuni.denominazione%TYPE
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
    , p_sigla_provincia_dom     IN   ad4_province.sigla%TYPE DEFAULT NULL
    , p_descr_comune_dom        IN   ad4_comuni.denominazione%TYPE
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
    , p_competenza_esclusiva    IN   anagrafe_soggetti.competenza_esclusiva%TYPE
            DEFAULT NULL
    , p_tipo_soggetto           IN   anagrafe_soggetti.tipo_soggetto%TYPE
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
   );
   FUNCTION exists_slave /* SLAVE_COPY */
   return number;
   PROCEDURE refresh_slave
   ( p_onerror_raise in number default 0
   );
   -- Messaggio previsto per il numero di eccezione indicato
   function error_message  /* SLAVE_COPY */
   ( p_err_number  in AFC_Error.t_error_number
   ) return AFC_Error.t_error_msg;
   -- Emette raise_application_error del messaggio previsto
   -- per il numero di eccezione indicato
   procedure raise_error_message
   ( p_error_number  in AFC_Error.t_error_number
   , p_precisazione in varchar2 default null
   );
     -- Verifica che il soggetto modificato sia di competenza
   function is_competenza_ok
   ( p_competenza in anagrafe_soggetti.competenza%type
   , p_competenza_esclusiva in anagrafe_soggetti.competenza_esclusiva%type
   , p_competenza_old in anagrafe_soggetti.competenza%type
   , p_competenza_esclusiva_old in anagrafe_soggetti.competenza_esclusiva%type
   ) return AFC_Error.t_error_number;
   function scegli_fra_anagrafe_soggetti
   ( p_codice_fiscale in anagrafe_soggetti.codice_fiscale%TYPE
   , p_competenza in anagrafe_soggetti.competenza%TYPE default '%'
   ) return number;
END anagrafe_soggetti_pkg;
/

