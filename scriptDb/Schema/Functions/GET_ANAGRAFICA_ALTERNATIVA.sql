CREATE OR REPLACE FUNCTION get_anagrafica_alternativa (
   p_ni                                anagrafici.ni%TYPE,
   p_cognome                           anagrafici.cognome%TYPE,
   p_nome                              anagrafici.nome%TYPE,
   p_partita_iva                       anagrafici.partita_iva%TYPE,
   p_codice_fiscale                    anagrafici.codice_fiscale%TYPE,
   p_competenza                 IN     ANAGRAFICI.competenza%TYPE DEFAULT NULL,
   p_id_anagrafica_utilizzare   IN OUT anagrafici.id_anagrafica%TYPE -- se ritorno nullo inserire altrimenti
                                                                    -- usare id ritornato
   )                                     --U=update, I=insert, D=Cancellazione
   RETURN NUMBER -- ni da utilizzare o null se non ha trovato una anagrafica alternativa
/*************************************************************
RITORNO:
        null = non trovati soggetti in competizione inseerisco nuovo soggetto
        -1   = inserire il record passato come parametro chiuso logicamente
               e stato chiuso
        n positivo = ni da utilizzare come anagrafica e inserire
           se dovevo storicizzare viene fatto nel trigger
*************************************************************/
IS
   v_ni_da_usare   anagrafici.ni%TYPE;
   v_get_pref_alternativa impostazioni.t_impostazioni;
BEGIN
   v_get_pref_alternativa := impostazioni.get_preferenza ('RicercaAnagrafeAlternativa', '') ;
   IF upper(v_get_pref_alternativa) in ('NO') then        -- caso base
     -- al momento non fa NULLA
     null;
   ELSIF upper(v_get_pref_alternativa) in ('YES','SI') then        -- caso base
     -- al momento non fa NULLA
      v_ni_da_usare :=
         ANAGRAFICA_PERSONALIZZAZIONI.GET_ANAGRAFICA_ALTERNATIVA (
            p_ni,
            p_cognome,
            p_nome,
            p_partita_iva,
            p_codice_fiscale,
            p_competenza,
            p_id_anagrafica_utilizzare);   
   ELSIF  v_get_pref_alternativa = 'VENEZIA'
   THEN
      v_ni_da_usare :=
         ANAGRAFICA_PERSONALIZZAZIONI.get_anag_alternativa_VENEZIA (
            p_ni,
            p_cognome,
            p_nome,
            p_partita_iva,
            p_codice_fiscale,
            p_competenza,
            p_id_anagrafica_utilizzare);
   END IF;

   RETURN v_ni_da_usare;
END;
/

