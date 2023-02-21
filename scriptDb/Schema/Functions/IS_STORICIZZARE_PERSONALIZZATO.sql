CREATE OR REPLACE FUNCTION IS_STORICIZZARE_PERSONALIZZATO (
   p_ni              IN anagrafici.ni%TYPE,
   p_dal             IN anagrafici.dal%TYPE,
   p_tipo_soggetto   IN anagrafici.tipo_soggetto%TYPE,
   p_cognome         IN anagrafici.cognome%TYPE,
   p_nome            IN anagrafici.nome%TYPE)
   RETURN AFC_Error.t_error_number
/*************************************************************
RITORNO:
        1 = se da storicizzare
        0 = DEVO non storicizzare

 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
 10  12/04/2019  SNeg Se parametro = NO non deve storicizzare Bug #34384
*************************************************************/
IS
   d_result   AFC_Error.t_error_number := AFC_Error.ok;
   v_get_pref_storicizzare impostazioni.t_impostazioni;
BEGIN
   v_get_pref_storicizzare := impostazioni.get_preferenza ('Storicizzare', '') ;
   IF upper(v_get_pref_storicizzare) in ('NO') then        -- caso base
     d_result := 0; -- NON storicizzare
   ELSIF upper(v_get_pref_storicizzare) in ('YES','SI') then
     -- al momento non fa NULLA                                                          -- caso base
      d_result :=
         ANAGRAFICA_PERSONALIZZAZIONI.IS_STORICIZZARE_PERSONALIZZATO (
            p_ni,
            p_dal,
            p_tipo_soggetto,
            p_cognome,
            p_nome);
   ELSIF v_get_pref_storicizzare = 'VENEZIA'
   THEN
      d_result :=
         ANAGRAFICA_PERSONALIZZAZIONI.IS_STORICIZZARE_PERS_VENEZIA (
            p_ni,
            p_dal,
            p_tipo_soggetto,
            p_cognome,
            p_nome);
   ELSE
       null;
   END IF;

   RETURN d_result;
END;
/

