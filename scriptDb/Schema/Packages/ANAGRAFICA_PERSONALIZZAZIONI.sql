CREATE OR REPLACE PACKAGE ANAGRAFICA_PERSONALIZZAZIONI
IS
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';

   --------------------------------------------------------------------------------
   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION IS_MODIFICABILE_PERS_VENEZIA (
      p_ni                         IN anagrafici.ni%TYPE,
      p_dal                        IN anagrafici.dal%TYPE,
      p_competenza                 IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
      p_competenza_old             IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
      RETURN AFC_Error.t_error_number;

   FUNCTION IS_MODIFICABILE_PERSONALIZZATO (
      p_ni                         IN anagrafici.ni%TYPE,
      p_dal                        IN anagrafici.dal%TYPE,
      p_competenza                 IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
      p_competenza_old             IN anagrafici.competenza%TYPE,
      p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
      RETURN AFC_Error.t_error_number;

   FUNCTION IS_STORICIZZARE_PERS_VENEZIA (
      p_ni              IN anagrafici.ni%TYPE,
      p_dal             IN anagrafici.dal%TYPE,
      p_tipo_soggetto   IN anagrafici.tipo_soggetto%TYPE,
      p_cognome         IN anagrafici.cognome%TYPE,
      p_nome            IN anagrafici.nome%TYPE)
      RETURN AFC_Error.t_error_number;

   FUNCTION IS_STORICIZZARE_PERSONALIZZATO (
      p_ni              IN anagrafici.ni%TYPE,
      p_dal             IN anagrafici.dal%TYPE,
      p_tipo_soggetto   IN anagrafici.tipo_soggetto%TYPE,
      p_cognome         IN anagrafici.cognome%TYPE,
      p_nome            IN anagrafici.nome%TYPE)
      RETURN AFC_Error.t_error_number;

   FUNCTION get_anag_alternativa_VENEZIA (
      p_ni                                anagrafici.ni%TYPE,
      p_cognome                           anagrafici.cognome%TYPE,
      p_nome                              anagrafici.nome%TYPE,
      p_partita_iva                       anagrafici.partita_iva%TYPE,
      p_codice_fiscale                    anagrafici.codice_fiscale%TYPE,
      p_competenza                 IN     ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_id_anagrafica_utilizzare   IN OUT anagrafici.id_anagrafica%TYPE)
      RETURN NUMBER;

   FUNCTION GET_ANAGRAFICA_ALTERNATIVA (
      p_ni                                anagrafici.ni%TYPE,
      p_cognome                           anagrafici.cognome%TYPE,
      p_nome                              anagrafici.nome%TYPE,
      p_partita_iva                       anagrafici.partita_iva%TYPE,
      p_codice_fiscale                    anagrafici.codice_fiscale%TYPE,
      p_competenza                 IN     ANAGRAFICI.competenza%TYPE DEFAULT NULL,
      p_id_anagrafica_utilizzare   IN OUT anagrafici.id_anagrafica%TYPE)
      RETURN NUMBER;
END;
/

