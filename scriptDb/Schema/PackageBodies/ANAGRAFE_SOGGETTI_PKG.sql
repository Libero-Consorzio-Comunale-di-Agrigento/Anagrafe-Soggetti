CREATE OR REPLACE PACKAGE BODY anagrafe_soggetti_pkg
IS
/******************************************************************************
 NOME:        anagrafe_soggetti_pkg
 DESCRIZIONE: Gestione tabella anagrafe_soggetti.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   04/07/2007  VDAVALLI  Prima emissione.
 001   29/10/2008  Snegroni  Aggiunta init_ni
 002   23/11/2009    MMalferrari Aggiunta funzione init_ni
 003  28/11/2011  Snegroni Aggiunta is_competenza_ok
 004  05/12/2011  SNegroni Aggiunta scegli_fra_anagrafe_soggetti
 005  05/09/2012  SNegroni Se codice fiscale passato e 16 'X' non bisogna considerarlo
 006  31/01/2013 SNegroni controllo che il soggetto sia valido NON che al sia nullo
 007  27/03/2013 SNegroni Correzione errato controllo sul codice fiscale
 008  19/02/2019 SNegroni Tolto il controllo sugli slave che non esistono piu
 009  01/07/2019 SNegroni Scegliere soggetto in struttura con il codice fiscale dato
 010  22/06/2020 SNegroni Distribuzione richieste di MOnica Sarti x CCBZ
 011  30/10/2020 SNegroni Distribzione modifica x gestire c.f. x 730 precompilati (Sarti) #45711
******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision          := '011';
   s_error_table AFC_Error.t_error_table;
   comp_escl_no_progetto exception;
   pragma exception_init( comp_escl_no_progetto, -20911 );
   s_comp_escl_no_progetto_number constant AFC_Error.t_error_number := -20911;
   s_comp_escl_no_progetto_msg constant AFC_Error.t_error_msg := 'A10001';
   comp_escl_altrui exception;
   pragma exception_init(comp_escl_altrui, -20912 );
   s_comp_escl_altrui_number constant AFC_Error.t_error_number := -20912;
   s_comp_escl_altrui_msg constant AFC_Error.t_error_msg := 'A10002';
   comp_altrui exception;
   pragma exception_init( comp_altrui, -20913 );
   s_comp_altrui_number constant AFC_Error.t_error_number := -20913;
   s_comp_altrui_msg constant AFC_Error.t_error_msg := 'A10003';
    comu_sigla_prov exception;
   pragma exception_init( comu_sigla_prov, -20941 );
   s_comu_sigla_prov_num constant AFC_Error.t_error_number := -20941;
   s_comu_sigla_prov_msg constant AFC_Error.t_error_msg := 'A10041';
   CURSOR cur_slave
   IS
      SELECT DISTINCT db_link db_link
        FROM ad4_istanze, ad4_slaves
       WHERE progetto = 'AS4'
         AND (   INSTR ('.' || installazione || '.'
                      , '.SLAVEGEOU.'
                       ) > 0
              OR INSTR ('.' || installazione || '.'
                      , '.SLAVEGEO.'
                       ) > 0
             )
         AND UPPER (ad4_slaves.link_oracle) = UPPER (ad4_istanze.link_oracle)
         AND STATO = 'A'
   ;
--------------------------------------------------------------------------------
   FUNCTION versione
      RETURN VARCHAR2
   IS /* SLAVE_COPY */
/******************************************************************************
 NOME:        versione
 DESCRIZIONE: Versione e revisione di distribuzione del package.
 RITORNA:     varchar2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilita del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;                             -- anagrafe_soggetti_pkg.versione
--------------------------------------------------------------------------------
procedure init_error_table
is
/******************************************************************************
 NOME:        init_error_table
 DESCRIZIONE: Riempie la tabella degli errori con i messaggi relativi.
******************************************************************************/
begin
   -- inserimento degli errori nella tabella
   s_error_table( s_comp_escl_no_progetto_number ) := si4.get_error(s_comp_escl_no_progetto_msg);
   s_error_table( s_comp_escl_altrui_number ) := si4.get_error(s_comp_escl_altrui_msg);
   s_error_table( s_comp_altrui_number ) := si4.get_error(s_comp_altrui_msg);
   s_error_table( s_comu_sigla_prov_num ) := si4.get_error(s_comu_sigla_prov_msg);
 end init_error_table;
   function error_message
( p_err_number  in AFC_Error.t_error_number
) return AFC_Error.t_error_msg is
/******************************************************************************
 NOME:        error_message
 DESCRIZIONE: Messaggio previsto per il numero di eccezione indicato.
 NOTE:        Restituisce il messaggio abbinato al numero indicato nella tabella
              s_error_table del Package. Se p_error_number non e presente nella
              tabella s_error_table viene lanciata l'exception -20011
              (vedi AFC_Error).
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  28/06/2007 MM     Prima emissione.
******************************************************************************/
   d_result AFC_Error.t_error_msg;
begin
   if s_error_table.exists( p_err_number )
   then
      d_result := s_error_table( p_err_number );
   else
      raise_application_error( AFC_Error.exception_not_in_table_number
                             , AFC_Error.exception_not_in_table_msg
                             );
   end if;
   return  d_result;
end error_message; -- anagrafe_soggetti_pkg.error_message
procedure raise_error_message
( p_error_number  in AFC_Error.t_error_number
, p_precisazione in varchar2 default null
) is
/******************************************************************************
 NOME:        raise_error_message
 DESCRIZIONE: Emette raise_application_error del messaggio previsto per il
              numero di eccezione indicato.
 ARGOMENTI:   p_error_number   numero di eccezione da lanciare
              p_precisazione   eventuale precisazione
 NOTE:        Se p_error_number non e presente nella tabella s_error_table
              viene lanciata l'exception -20011 (vedi AFC_Error).
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  28/06/2007 MM     Prima emissione.
******************************************************************************/
   d_result AFC_Error.t_error_msg;
begin
   d_result := error_message(  p_err_number => p_error_number);
   raise_application_error( p_error_number
                          , s_error_table( p_error_number )||' '||p_precisazione
                          );
end raise_error_message;
--------------------------------------------------------------------------------
   FUNCTION get_rows (
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
      RETURN afc.t_ref_cursor
   IS /* SLAVE_COPY */
/******************************************************************************
 NOME:        get_rows
 DESCRIZIONE: Ritorna il risultato di una query in base ai valori che passiamo.
 PARAMETRI:   Chiavi e attributi della table
              p_other_condition
              p_QBE 0: se l'operatore da utilizzare nella where-condition e
                       quello di default ('=')
                    1: se l'operatore da utilizzare nella where-condition e
                       quello specificato per ogni attributo.
 RITORNA:     Un ref_cursor che punta al risultato della query.
 NOTE:        Se p_QBE = 1 , ogni parametro deve contenere, nella prima parte,
              l'operatore da utilizzare nella where-condition.
******************************************************************************/
      d_ref_cursor      afc.t_ref_cursor;
      d_provincia_nas   anagrafe_soggetti.provincia_nas%TYPE;
      d_comune_nas      anagrafe_soggetti.comune_nas%TYPE;
      d_provincia_res   anagrafe_soggetti.provincia_res%TYPE;
      d_comune_res      anagrafe_soggetti.comune_res%TYPE;
      d_provincia_dom   anagrafe_soggetti.provincia_dom%TYPE;
      d_comune_dom      anagrafe_soggetti.comune_dom%TYPE;
      d_error           AFC_Error.t_error_number := AFC_Error.ok;
   BEGIN
    init_error_table;
   if    (p_sigla_provincia_nas is null and p_descr_comune_nas is not null)
      or (p_sigla_provincia_nas is not null and p_descr_comune_nas is null)
   then
      d_error := s_comu_sigla_prov_num;
      s_error_table( d_error ) := s_error_table( d_error )||' (dati di nascita)';
   end if;
   if    (p_sigla_provincia_res is null and p_descr_comune_res is not null)
      or (p_sigla_provincia_res is not null and p_descr_comune_res is null)
   then
      d_error := s_comu_sigla_prov_num;
      s_error_table( d_error ) := s_error_table( d_error )||' (dati di residenza)';
   end if;
   if    (p_sigla_provincia_dom is null and p_descr_comune_dom is not null)
      or (p_sigla_provincia_dom is not null and p_descr_comune_dom is null)
   then
      d_error := s_comu_sigla_prov_num;
      s_error_table( d_error ) := s_error_table( d_error )||' (dati di domicilio)';
   end if;
     if d_error != AFC_Error.ok
     then
      raise_error_message ( d_error );
      end if;
      IF p_sigla_provincia_nas IS NOT NULL AND p_descr_comune_nas IS NOT NULL
      THEN
         d_provincia_nas :=
            ad4_comune.get_provincia
               (p_denominazione        => p_descr_comune_nas
              , p_sigla_provincia      => p_sigla_provincia_nas
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_nas
                                            , p_sigla_provincia      => p_sigla_provincia_nas)
               );
         d_comune_nas :=
            ad4_comune.get_comune
               (p_denominazione        => p_descr_comune_nas
              , p_sigla_provincia      => p_sigla_provincia_nas
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_nas
                                            , p_sigla_provincia      => p_sigla_provincia_nas)
               );
      ELSE
         d_provincia_nas := NULL;
         d_comune_nas := NULL;
      END IF;
      IF p_sigla_provincia_res IS NOT NULL AND p_descr_comune_res IS NOT NULL
      THEN
         d_provincia_res :=
            ad4_comune.get_provincia
               (p_denominazione        => p_descr_comune_res
              , p_sigla_provincia      => p_sigla_provincia_res
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_res
                                            , p_sigla_provincia      => p_sigla_provincia_res)
               );
         d_comune_res :=
            ad4_comune.get_comune
               (p_denominazione        => p_descr_comune_res
              , p_sigla_provincia      => p_sigla_provincia_res
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_res
                                            , p_sigla_provincia      => p_sigla_provincia_res)
               );
      ELSE
         d_provincia_res := NULL;
         d_comune_res := NULL;
      END IF;
      IF p_sigla_provincia_dom IS NOT NULL AND p_descr_comune_dom IS NOT NULL
      THEN
         d_provincia_dom :=
            ad4_comune.get_provincia
               (p_denominazione        => p_descr_comune_dom
              , p_sigla_provincia      => p_sigla_provincia_dom
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_dom
                                            , p_sigla_provincia      => p_sigla_provincia_dom)
               );
         d_comune_dom :=
            ad4_comune.get_comune
               (p_denominazione        => p_descr_comune_dom
              , p_sigla_provincia      => p_sigla_provincia_dom
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_dom
                                            , p_sigla_provincia      => p_sigla_provincia_dom)
               );
      ELSE
         d_provincia_dom := NULL;
         d_comune_dom := NULL;
      END IF;
      d_ref_cursor :=
         anagrafe_soggetti_tpk.get_rows
                          (p_ni                         => p_ni
                         , p_dal                        => p_dal
                         , p_cognome                    => p_cognome
                         , p_nome                       => p_nome
                         , p_sesso                      => p_sesso
                         , p_data_nas                   => p_data_nas
                         , p_provincia_nas              => d_provincia_nas
                         , p_comune_nas                 => d_comune_nas
                         , p_luogo_nas                  => p_luogo_nas
                         , p_codice_fiscale             => p_codice_fiscale
                         , p_codice_fiscale_estero      => p_codice_fiscale_estero
                         , p_partita_iva                => p_partita_iva
                         , p_cittadinanza               => p_cittadinanza
                         , p_gruppo_ling                => p_gruppo_ling
                         , p_indirizzo_res              => p_indirizzo_res
                         , p_provincia_res              => d_provincia_res
                         , p_comune_res                 => d_comune_res
                         , p_cap_res                    => p_cap_res
                         , p_tel_res                    => p_tel_res
                         , p_fax_res                    => p_fax_res
                         , p_presso                     => p_presso
                         , p_indirizzo_dom              => p_indirizzo_dom
                         , p_provincia_dom              => d_provincia_dom
                         , p_comune_dom                 => d_comune_dom
                         , p_cap_dom                    => p_cap_dom
                         , p_tel_dom                    => p_tel_dom
                         , p_fax_dom                    => p_fax_dom
                         , p_utente                     => p_utente
                         , p_data_agg                   => p_data_agg
                         , p_competenza                 => p_competenza
                         , p_competenza_esclusiva       => p_competenza_esclusiva
                         , p_tipo_soggetto              => p_tipo_soggetto
                         , p_stato_cee                  => p_stato_cee
                         , p_partita_iva_cee            => p_partita_iva_cee
                         , p_fine_validita              => p_fine_validita
                         , p_al                         => p_al
                         , p_denominazione              => p_denominazione
                         , p_indirizzo_web              => p_indirizzo_web
                         , p_note                       => p_note
                         , p_other_condition            => p_other_condition
                         , p_qbe                        => p_qbe
                          );
      RETURN d_ref_cursor;
   END get_rows;                             -- anagrafe_soggetti_tpk.get_rows
--------------------------------------------------------------------------------
   PROCEDURE init_ni (
      p_ni   IN OUT   anagrafe_soggetti.ni%TYPE
   )
   IS
/******************************************************************************
 NOME:        init_ni.
 DESCRIZIONE: Valorizza il campo NI.
 ARGOMENTI:   p_ni   IN OUT number campo NI.
 NOTE:        Valorizza il parametro p_ni, se nullo, con il primo valore libero
              della sequence SOGG_SQ.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  28/06/2007 MM     Prima emissione.
******************************************************************************/
   BEGIN
      IF p_ni IS NULL
      THEN
         SELECT sogg_sq.NEXTVAL
           INTO p_ni
           FROM DUAL;
      END IF;
   END init_ni;
   FUNCTION init_ni RETURN NUMBER
/******************************************************************************
 NOME:        init_ni.
 DESCRIZIONE: Valorizza il campo NI.
 ARGOMENTI:   p_ni   IN OUT number campo NI.
 NOTE:        Valorizza il parametro p_ni, se nullo, con il primo valore libero
              della sequence SOGG_SQ.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 002  23/11/2009 MM     Prima emissione.
******************************************************************************/
   IS
      d_return number;
   BEGIN
      init_ni(d_return);
      return d_return;
   END init_ni;
   PROCEDURE ins (
      p_ni                      IN   anagrafe_soggetti.ni%TYPE
    , p_dal                     IN   anagrafe_soggetti.dal%TYPE
    , p_cognome                 IN   anagrafe_soggetti.cognome%TYPE
    , p_nome                    IN   anagrafe_soggetti.nome%TYPE DEFAULT NULL
    , p_sesso                   IN   anagrafe_soggetti.sesso%TYPE DEFAULT NULL
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
   )
   IS
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
      d_provincia_nas   anagrafe_soggetti.provincia_nas%TYPE;
      d_comune_nas      anagrafe_soggetti.comune_nas%TYPE;
      d_provincia_res   anagrafe_soggetti.provincia_res%TYPE;
      d_comune_res      anagrafe_soggetti.comune_res%TYPE;
      d_provincia_dom   anagrafe_soggetti.provincia_dom%TYPE;
      d_comune_dom      anagrafe_soggetti.comune_dom%TYPE;
      d_error           number := 0;
   BEGIN
      IF    (p_sigla_provincia_nas IS NULL AND p_descr_comune_nas IS NOT NULL
            )
         OR (p_sigla_provincia_nas IS NOT NULL AND p_descr_comune_nas IS NULL
            )
      THEN
         d_error := -20901;
      END IF;
      IF d_error = 0 THEN
         IF    (p_sigla_provincia_res IS NULL AND p_descr_comune_res IS NOT NULL
               )
            OR (p_sigla_provincia_res IS NOT NULL AND p_descr_comune_res IS NULL
               )
         THEN
            d_error := -20902;
         END IF;
         IF d_error = 0 THEN
            IF    (p_sigla_provincia_dom IS NULL AND p_descr_comune_dom IS NOT NULL
                  )
               OR (p_sigla_provincia_dom IS NOT NULL AND p_descr_comune_dom IS NULL
                  )
            THEN
               d_error := -20903;
            END IF;
         END IF;
      END IF;
      if d_error <> 0 then
         raise_application_error (d_error, error_message(p_err_number => d_error));
      end if;
      IF p_sigla_provincia_nas IS NOT NULL AND p_descr_comune_nas IS NOT NULL
      THEN
         d_provincia_nas :=
            ad4_comune.get_provincia
               (p_denominazione        => p_descr_comune_nas
              , p_sigla_provincia      => p_sigla_provincia_nas
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_nas
                                            , p_sigla_provincia      => p_sigla_provincia_nas)
               );
         d_comune_nas :=
            ad4_comune.get_comune
               (p_denominazione        => p_descr_comune_nas
              , p_sigla_provincia      => p_sigla_provincia_nas
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_nas
                                            , p_sigla_provincia      => p_sigla_provincia_nas)
               );
      ELSE
         d_provincia_nas := NULL;
         d_comune_nas := NULL;
      END IF;
      IF p_sigla_provincia_res IS NOT NULL AND p_descr_comune_res IS NOT NULL
      THEN
         d_provincia_res :=
            ad4_comune.get_provincia
               (p_denominazione        => p_descr_comune_res
              , p_sigla_provincia      => p_sigla_provincia_res
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_res
                                            , p_sigla_provincia      => p_sigla_provincia_res)
               );
         d_comune_res :=
            ad4_comune.get_comune
               (p_denominazione        => p_descr_comune_res
              , p_sigla_provincia      => p_sigla_provincia_res
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_res
                                            , p_sigla_provincia      => p_sigla_provincia_res)
               );
      ELSE
         d_provincia_res := NULL;
         d_comune_res := NULL;
      END IF;
      IF p_sigla_provincia_dom IS NOT NULL AND p_descr_comune_dom IS NOT NULL
      THEN
         d_provincia_dom :=
            ad4_comune.get_provincia
               (p_denominazione        => p_descr_comune_dom
              , p_sigla_provincia      => p_sigla_provincia_dom
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_dom
                                            , p_sigla_provincia      => p_sigla_provincia_dom)
               );
         d_comune_dom :=
            ad4_comune.get_comune
               (p_denominazione        => p_descr_comune_dom
              , p_sigla_provincia      => p_sigla_provincia_dom
              , p_soppresso            => ad4_comune.is_soppresso
                                             (p_denominazione        => p_descr_comune_dom
                                            , p_sigla_provincia      => p_sigla_provincia_dom)
               );
      ELSE
         d_provincia_dom := NULL;
         d_comune_dom := NULL;
      END IF;
      anagrafe_soggetti_tpk.ins
                          (p_ni                         => p_ni
                         , p_dal                        => p_dal
                         , p_cognome                    => p_cognome
                         , p_nome                       => p_nome
                         , p_sesso                      => p_sesso
                         , p_data_nas                   => p_data_nas
                         , p_provincia_nas              => d_provincia_nas
                         , p_comune_nas                 => d_comune_nas
                         , p_luogo_nas                  => p_luogo_nas
                         , p_codice_fiscale             => p_codice_fiscale
                         , p_codice_fiscale_estero      => p_codice_fiscale_estero
                         , p_partita_iva                => p_partita_iva
                         , p_cittadinanza               => p_cittadinanza
                         , p_gruppo_ling                => p_gruppo_ling
                         , p_indirizzo_res              => p_indirizzo_res
                         , p_provincia_res              => d_provincia_res
                         , p_comune_res                 => d_comune_res
                         , p_cap_res                    => p_cap_res
                         , p_tel_res                    => p_tel_res
                         , p_fax_res                    => p_fax_res
                         , p_presso                     => p_presso
                         , p_indirizzo_dom              => p_indirizzo_dom
                         , p_provincia_dom              => d_provincia_dom
                         , p_comune_dom                 => d_comune_dom
                         , p_cap_dom                    => p_cap_dom
                         , p_tel_dom                    => p_tel_dom
                         , p_fax_dom                    => p_fax_dom
                         , p_utente                     => p_utente
                         , p_data_agg                   => p_data_agg
                         , p_competenza                 => p_competenza
                         , p_competenza_esclusiva       => p_competenza_esclusiva
                         , p_tipo_soggetto              => p_tipo_soggetto
                         , p_stato_cee                  => p_stato_cee
                         , p_partita_iva_cee            => p_partita_iva_cee
                         , p_fine_validita              => p_fine_validita
                         , p_al                         => p_al
                         , p_denominazione              => p_denominazione
                         , p_indirizzo_web              => p_indirizzo_web
                         , p_note                       => p_note
                          );
   END;
   FUNCTION exists_slave
   return number
   IS /* SLAVE_COPY */
/******************************************************************************
 NOME:        exists_slave
 DESCRIZIONE: Gestione tabella anagrafe_soggetti.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 008  19/02/2019 SNegroni Tolto il controllo sugli slave che non esistono più
******************************************************************************/
      d_db_link varchar2(1000);
   BEGIN
--      IF NOT cur_slave%ISOPEN THEN
--         OPEN cur_slave;
--      END IF;
--      FETCH cur_slave INTO d_db_link;
--      if cur_slave%FOUND then
--         close cur_slave;
--         return 1;
--      else
--         close cur_slave;
         return 0;
--      end if;
   END exists_slave;
   PROCEDURE refresh_slave
   ( p_onerror_raise in number default 0
   )
   IS
      d_onerror_raise number := nvl(p_onerror_raise, 0);
      pragma autonomous_transaction;
      d_db_link varchar2(1000);
   BEGIN
-- X SISTEMARE Materialized view se installazione master/slave
      IF NOT cur_slave%ISOPEN THEN
         OPEN cur_slave;
      ELSE
         close cur_slave;
         OPEN cur_slave;
      END IF;
      FETCH cur_slave INTO d_db_link;
      WHILE cur_slave%FOUND
      LOOP
         begin
            EXECUTE IMMEDIATE (   'begin DBMS_SNAPSHOT.REFRESH@'
                               || d_db_link
                               || '(LIST=>''ANAGRAFE_SOGGETTI'');end;'
                              );
            commit;
         exception
            when others then
               rollback;
               if p_onerror_raise = 1 then
                  close cur_slave;
                  raise;
               end if;
         end;
         FETCH cur_slave INTO d_db_link;
      END LOOP;
      close cur_slave;
   exception
      when others then
         rollback;
         raise;
   END refresh_slave;
   function get_progetto_competenza
( p_competenza in anagrafe_soggetti.competenza%type
) return anagrafe_soggetti.competenza%type
is
/******************************************************************************
 NOME:        get_progetto_competenza.
 DESCRIZIONE: Verifica che la competenza passata sia il codice di un progetto
              per cui esista almeno un'istanza collegata allo user che sta
              eseguendo l'operazione.
 PARAMETRI:   p_competenza competenza da verificare
 RITORNA:     codice del progetto di competenza
 NOTE:        Se la competenza passata e' nulla, restituisce il codice del
              primo progetto per cui esiste un'istanza collegata allo user che
              sta eseguendo l'operazione.
              Se non trova nessun progetto che soddisfa le condizioni, ritorna
              NULL.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  28/06/2007 MM     Prima emissione.
******************************************************************************/
   d_competenza anagrafe_soggetti.competenza%type;
begin
   SELECT MIN (progetto)
     INTO d_competenza
     FROM ad4_istanze
    WHERE progetto = nvl(UPPER (p_competenza), progetto)
      AND UPPER (user_oracle) = UPPER (USER)
   ;
   return d_competenza;
exception
   when no_data_found then
      return '';
end get_progetto_competenza;
function is_competenza_ok
( p_competenza in anagrafe_soggetti.competenza%type
, p_competenza_esclusiva in anagrafe_soggetti.competenza_esclusiva%type
, p_competenza_old in anagrafe_soggetti.competenza%type
, p_competenza_esclusiva_old in anagrafe_soggetti.competenza_esclusiva%type
) return AFC_Error.t_error_number
is
/******************************************************************************
 NOME:        is_competenza_ok.
 DESCRIZIONE: Verifica competenza sulla modifica del soggetto.
 PARAMETRI:   p_competenza                IN   competenza
              p_competenza_esclusiva      IN   competenza esclusiva
              p_competenza_old            IN   precedente competenza
              p_competenza_esclusiva_old  IN   precedente competenza esclusiva
 RITORNA:     number
              se verifica effettuata con successo
                  afc_error.ok (1)
              altrimenti,
                   codice di errore.
 NOTE:        Verifica la competenza sulla modifica del soggetto secondo le
              seguenti regole:
              1. Il soggetto non e' modificabile perche' di competenza di altro
                 progetto (codice s_comp_altrui_number) se:
                 -   e' di competenza di un progetto (p_competenza_old non nullo)
                     e la nuova competenza non e' specificata (p_competenza nullo);
                 -   e' di competenza esclusiva di un progetto diverso da quello
                     passato o su cui lo user che esegue l'operazione non ha
                     competenza;
                 -   si vuole renderlo di competenza esclusiva di un progetto su
                     cui lo user che esegue l'operazione non ha competenza;
                 -   e' di competenza di un progetto con priorita' maggiore.
              2. Il soggetto non e' modificabile perche' si vuole renderlo di
                 competenza esclusiva ma non si specifica di quale progetto
                 (s_comp_escl_no_progetto_number).
              Alla descrizione dell'eventuale errore nella riga corrispondente
              della tabella degli errori viene aggiunto il codice del progetto
              competente.
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  28/06/2007 MM     Prima emissione.
******************************************************************************/
   d_result AFC_Error.t_error_number := AFC_Error.ok;
   D_new_priorita   NUMBER;
   D_old_priorita   NUMBER;
   D_messaggio      VARCHAR2 (255);
   d_competenza     anagrafe_soggetti.competenza%type;
BEGIN
   init_error_table;
     DECLARE
         d_new_priorita   NUMBER;
         d_old_priorita   NUMBER;
         d_progetto       VARCHAR2 (60);
         d_messaggio      VARCHAR2 (255);
      BEGIN
         IF substr(nvl(NVL (p_competenza_old, p_competenza), 'xxx'), 1, 2) <> substr(nvl(p_competenza, 'xxx'), 1, 2)
         THEN
            BEGIN
               SELECT priorita
                 INTO d_new_priorita
                 FROM ad4_progetti
                WHERE progetto = p_competenza;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_new_priorita := 0;
            END;
            BEGIN
               SELECT priorita, descrizione
                 INTO d_old_priorita, d_progetto
                 FROM ad4_progetti
                WHERE progetto = p_competenza_OLD;
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_old_priorita := 0;
            END;
            -- Se il progetto ha priorita' minore o se il cliente non ha impostato
            -- la priorita' tra i progetti, non permette la modifica
            IF    NVL (d_new_priorita, 0) < NVL (d_old_priorita, 0)
               OR (d_new_priorita IS NULL AND d_old_priorita IS NULL)
            THEN
             d_result := s_comp_altrui_number;--
--               raise_application_error
--                                   (-20999
--                                  ,    'Soggetto di competenza del progetto '
--                                    || d_progetto
--                                    || ' non modificabile !');
            END IF;
            -- Rev.10 del 01/09/2009 MM: A34101.0.0: gestione competenza esclusiva del record.
            if nvl(p_competenza_esclusiva_OLD, 'x') = 'E' then
             d_result := s_comp_escl_altrui_number;--
--               raise_application_error
--                                   (-20999
--                                  ,    'Soggetto di competenza esclusiva del progetto '
--                                    || d_progetto
--                                    || ' non modificabile !');
            end if;
            -- Rev.10 del 01/09/2009 MM : A34101.0.0: fine mod.
         END IF;
      END;
   if d_result != afc_error.ok
   then
      s_error_table( d_result ) := s_error_table( d_result )||' ('||p_competenza_old||')';
   end if;
   return d_result;
end is_competenza_ok;


FUNCTION SCEGLI_FRA_ANAGRAFE_SOGGETTI
   (p_codice_fiscale in anagrafe_soggetti.codice_fiscale%TYPE
   ,p_competenza in anagrafe_soggetti.competenza%TYPE default '%'
   ) RETURN number
   IS
/******************************************************************************
 NOME:        scegli_fra_soggetti.
 DESCRIZIONE: Sceglie fra i soggetti in anagrafica con il codice fiscale passato come parametro quello
                       da utilizzare nell'applicativo chiamante per assegnare nuovi dirititi di accesso o da usare
                       come componente.
 PARAMETRI:   p_codice_fiscale                IN   p_codice_fiscale
              p_competenza      IN   competenza
 RITORNA:     number
              se trovato gia record
              altrimenti,
                   NULL.
 NOTE:        Sceglie il soggetto secondo le seguenti precedenze:
              1. Il soggetto ha un utente abbinato
              2. Il soggetto ha un utente e diritti di accesso
              3. Il soggetto ha la competenza indicata come parametro
              Nel caso in cui piu soggetti soddisfino i requisiti ne prende
              uno a caso (max).
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 000  05/10/2011 SNegroni     Prima emissione.
 005  05/09/2012 SNegroni Se codice fiscale passato e 16 'X' non bisogna considerarlo
 006  31/01/2013 SNegroni controllo che il soggetto sia valido NON che al sia nullo
 009  01/07/2019 SNegroni Scegliere soggetto in struttura con il codice fiscale dato
 010  22/06/2020 SNegroni Distribuzione richieste di MOnica Sarti
 011  27/10/2020 Msarti   Gestione Agenzia delle entrate di GPs-GP4 #45711
 ******************************************************************************/
   v_ni_soggetto anagrafe_soggetti.ni%TYPE;
   v_codice_fiscale anagrafe_soggetti.codice_fiscale%TYPE := p_codice_fiscale;
   BEGIN
-- dbms_output.put_line('p_codice_fiscale '||p_codice_fiscale);
   --
   IF  not(   length(p_codice_fiscale) = 16
      and ascii(upper(substr(ltrim(rtrim(p_codice_fiscale)),1,1))) between 65 and 90  -- inizia con lettera
      and ascii(upper(substr(ltrim(rtrim(p_codice_fiscale)),-1,1))) between 65 and 90 -- finisce con lettera
      )-- se non e un codice fiscale di un soggetto
   then
      v_codice_fiscale := null;
   end if;
   -- se con quel codice fiscale è in struttura uso quel soggetto
   select max(ni)
      into v_ni_soggetto
      from anagrafe_soggetti anso
     where anso.codice_fiscale = v_codice_fiscale
       and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
       and ad4_soggetto.is_soggetto_componente(ni) = 1
       and anso.competenza  like p_competenza;
   if v_ni_soggetto is null then
       select max(ni)
          into v_ni_soggetto
         from ad4_utenti_soggetti utso
               , anagrafe_soggetti anso
               , ad4_utenti uten
       where anso.codice_fiscale = v_codice_fiscale
           and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
           and uten.utente = utso.utente
           and anso.ni = utso.soggetto
           and exists (select 'x'
                              from ad4_diritti_accesso
                             where utente = uten.utente)
           and anso.competenza  like p_competenza
             ;
         if v_ni_soggetto is null then
             select max(ni)
              into v_ni_soggetto
             from ad4_utenti_soggetti utso
                   , anagrafe_soggetti anso
                   , ad4_utenti uten
           where anso.codice_fiscale = v_codice_fiscale
               and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
               and uten.utente = utso.utente
               and anso.ni = utso.soggetto
               and exists (select 'x'
                                  from ad4_diritti_accesso
                                 where utente = uten.utente)
                 ;
              if v_ni_soggetto is null then
                 select max(ni)
                  into v_ni_soggetto
                 from ad4_utenti_soggetti utso
                       , anagrafe_soggetti anso
                       , ad4_utenti uten
               where anso.codice_fiscale = v_codice_fiscale
                   and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
                   and uten.utente = utso.utente
                   and anso.ni = utso.soggetto
                     ;
                     if v_ni_soggetto is null then
                         select max(ni)
                          into v_ni_soggetto
                         from anagrafe_soggetti anso
                       where anso.codice_fiscale = v_codice_fiscale
                         and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
                             ;
                     end if;
             end if;
         end if;
     end if;
     -- 22/12/2019 - Monica aggiungo la ricerca per gli enti giuridici tipo i CAAF
     if v_ni_soggetto is null and length(p_codice_fiscale) = 11 and afc.is_numeric(p_codice_fiscale) = 1
     then
-- dbms_output.put_line('p_codice_fiscale '||p_codice_fiscale);
       select max(ni)
         into v_ni_soggetto
         from anagrafe_soggetti anso
        where anso.codice_fiscale = p_codice_fiscale
          and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
           -- and anso.competenza  like p_competenza
        ;
     end if;
     if p_codice_fiscale = '1'
     then -- MONICA forzatura per CCBZ
       select max(ni)
         into v_ni_soggetto
         from anagrafe_soggetti anso
        where anso.codice_fiscale = p_codice_fiscale
          and cognome = 'AGENZIA ENTRATE'
          and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
           -- and anso.competenza  like p_competenza
        ;
     end if;
     if p_codice_fiscale = 'XXXXXXXXXXX'
     and v_ni_soggetto is null
     then -- MONICA 27/10/2020 forzatura per CAAF AGENZIA ENTRATE PER 730 PRECOMPILATI
       select max(ni)
         into v_ni_soggetto
         from anagrafe_soggetti anso
        where anso.codice_fiscale = p_codice_fiscale
          and cognome like '%AGENZIA%ENTRATE%730%PRECOMPILA%'
          and sysdate between anso.dal and nvl(anso.al,trunc(sysdate) +1)
           -- and anso.competenza  like p_competenza
        ;
     end if;
     return v_ni_soggetto;
END SCEGLI_FRA_ANAGRAFE_SOGGETTI;

END anagrafe_soggetti_pkg;
/

