CREATE OR REPLACE FUNCTION IS_MODIFICABILE_PERSONALIZZATO (
   p_ni                         IN anagrafici.ni%TYPE,
   p_dal                        IN anagrafici.dal%TYPE,
   p_competenza                 IN anagrafici.competenza%TYPE,
   p_competenza_esclusiva       IN anagrafici.competenza_esclusiva%TYPE,
   p_competenza_old             IN anagrafici.competenza%TYPE,
   p_competenza_esclusiva_old   IN anagrafici.competenza_esclusiva%TYPE)
   RETURN AFC_Error.t_error_number
IS
   d_result   AFC_Error.t_error_number := 0;
   v_get_pref_modificabile impostazioni.t_impostazioni;
BEGIN
   v_get_pref_modificabile := impostazioni.get_preferenza ('Modificabile', '') ;
   IF upper(nvl(v_get_pref_modificabile,'SI')) ='SI' then        -- caso base
     -- al momento non fa NULLA
     d_result :=
         ANAGRAFICA_PERSONALIZZAZIONI.IS_MODIFICABILE_PERSONALIZZATO (
            p_ni,
            p_dal,
            p_competenza,
            p_competenza_esclusiva,
            p_competenza_old,
            p_competenza_esclusiva_old);
  ELSIF upper(v_get_pref_modificabile) ='VENEZIA'
   THEN
      d_result :=
         ANAGRAFICA_PERSONALIZZAZIONI.IS_MODIFICABILE_PERS_VENEZIA (
            p_ni,
            p_dal,
            p_competenza,
            p_competenza_esclusiva,
            p_competenza_old,
            p_competenza_esclusiva_old);
   END IF;
   RETURN d_result;
END;
/

